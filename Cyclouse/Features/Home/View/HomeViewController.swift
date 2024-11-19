//
//  HomeViewController.swift
//  Cyclouse
//
//  Created by yoga arie on 05/09/24.
//
import SnapKit
import UIKit
import Combine
import CombineCocoa
import EasyNotificationBadge
import JDStatusBarNotification
import Valet
import Hero
import ReactiveCollectionsKit


class HomeViewController: BaseViewController, CellEventCoordinator, UISearchResultsUpdating, UISearchControllerDelegate {
    
    // MARK: - Properties
    var coordinator: HomeCoordinator
    private let service = DatabaseService.shared
    var driver: CollectionViewDriver?
    var services = BikeService()
    var categories: [Category] = []
    var filteredProducts: [Product] = []
    
    var isSearching: Bool {
        return searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true)
    }
    
    var allProducts: [Product] {
        return categories.flatMap { $0.products }
    }
    
    // Hardcoded list of categories
    let allCategories = ["All", "Full Bike", "Handlebar", "Saddle", "Pedal", "Seatpost", "Stem", "Crank", "Wheelset", "Frame", "Tires"]
    var selectedCategory: String? = nil
  
    
    
    private var searchController: UISearchController!
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    // MARK: - Initialization
    
    init(coordinator: HomeCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
  
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
        // Remove setupNavigationVar() from here
        isLoading = true  // Start with loading state
      NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleFilterChange),
                name: NSNotification.Name("FilterSettingsChanged"),
                object: nil
            )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateBadge()
    }
    
    // MARK: - Setup Methods
    
    override func setupViews() {
        setupNavigationVar() // Call this before setupCollectionView()
        setupCollectionView()
    }
    
    override func setupConstraints() {
        collectionView.snp.makeConstraints {
            $0.left.right.top.bottom.equalToSuperview()
        }
    }
    
    override func bindViewModel() {
        updateBadge()
        if let userProfile = loadUserProfile() {
            showWelcomeNotification(with: userProfile)
        }
        simulateLoading()
        addObserver(forName: .paymentCompleted, selector: #selector(handlePaymentCompletion))
    }
    
    // MARK: - Loading State Methods
    
    override func updateLoadingState() {
        updateCollectionView()
    }
    
    // MARK: - Private Methods
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        driver = CollectionViewDriver(view: collectionView, viewModel: makeViewModel(), cellEventCoordinator: self)
    }
    
    private func simulateLoading() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.isLoading = false
            self?.fetchBikes()
        }
    }
  
    func didDismissSearchController(_ searchController: UISearchController) {
        updateCollectionView()
    }
    
    private func fetchBikes() {
        services.getBikes()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                    
                case .failure(let error):
                    print("Error fetching bikes: \(error)")
                    self.isLoading = false
                    self.updateCollectionView()
                }
            } receiveValue: { [weak self] bikeDataResponse in
                guard let self = self else { return }
                self.categories = bikeDataResponse.value.bikes.categories
                self.isLoading = false
                self.updateCollectionView()
            }
            .store(in: &cancellables)
    }
  
    // UISearchResultsUpdating Method
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        filterContentForSearchText(searchText)
    }

    // Filtering Method
    func filterContentForSearchText(_ searchText: String) {
        filteredProducts = allProducts.filter { product in
            return product.name.lowercased().contains(searchText.lowercased())
        }
        updateCollectionView()
    }
    
    private func updateCollectionView() {
        let viewModel = makeViewModel()
        driver?.update(viewModel: viewModel, animated: true)
        collectionView.collectionViewLayout = makeLayout()
    }
    
    private func makeViewModel() -> CollectionViewModel {
        var sections: [SectionViewModel] = []
        
        if isSearching {
            // Search Results Section
            let productCellViewModels = filteredProducts.map {
                BikeProductCellViewModel(product: $0, categoryName: $0.brand).eraseToAnyViewModel()
            }
            
            let searchResultsSection = SectionViewModel(
                id: "search_results",
                cells: productCellViewModels
            )
            
            sections.append(searchResultsSection)
        } else {
            // First Section: Categories
            let categoryCellViewModels = allCategories.map { categoryName in
                let isSelected = (categoryName == selectedCategory) || (selectedCategory == nil && categoryName == "All")
                return CategoryCellViewModel(category: categoryName, isSelected: isSelected).eraseToAnyViewModel()
            }
            
            let categorySectionHeader = SectionHeaderViewModel(
                id: "header_categories",
                title: "Categories"
            )
            
            let categorySection = SectionViewModel(
                id: "section_categories",
                cells: categoryCellViewModels,
                header: categorySectionHeader.eraseToAnyViewModel()
            )
            
            sections.append(categorySection)
            
            if isLoading {
                // Create Multiple Placeholder Sections
                let placeholderCategoryNames = ["Loading Category 1", "Loading Category 2", "Loading Category 3"]
                
                for placeholderCategoryName in placeholderCategoryNames {
                    // Create placeholder header view model
                    let loadingHeader = SectionHeaderViewModel(
                        id: "loading_header_\(placeholderCategoryName)",
                        isLoading: true
                    )
                    
                    // Placeholder cells
                    let placeholderCellViewModels = (0..<5).map { _ in
                        BikeProductCellViewModel(isLoading: true).eraseToAnyViewModel()
                    }
                    
                    let loadingSection = SectionViewModel(
                        id: "loading_section_\(placeholderCategoryName)",
                        cells: placeholderCellViewModels,
                        header: loadingHeader.eraseToAnyViewModel()
                    )
                    
                    sections.append(loadingSection)
                }
            } else {
                // Subsequent Sections: Bike Products
                let filteredCategories: [Category]
                if let selectedCategory = selectedCategory, selectedCategory != "All" {
                    filteredCategories = categories.filter { $0.categoryName == selectedCategory }
                } else {
                    filteredCategories = categories
                }
                
                for category in filteredCategories {
                    let productCellViewModels = category.products.map {
                        BikeProductCellViewModel(product: $0, categoryName: category.categoryName).eraseToAnyViewModel()
                    }
                    
                    let productSectionHeader = SectionHeaderViewModel(
                        id: "header_\(category.categoryName)",
                        title: category.categoryName
                    )
                    
                    let productSection = SectionViewModel(
                        id: "section_\(category.categoryName)",
                        cells: productCellViewModels,
                        header: productSectionHeader.eraseToAnyViewModel()
                    )
                    
                    sections.append(productSection)
                }
            }
        }
        
        return CollectionViewModel(
            id: "main_collection",
            sections: sections
        )
    }
    
    private func makeLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex, environment) -> NSCollectionLayoutSection? in
            
            guard let self = self else { return nil }
          
           
          if self.isSearching {
              // Layout for Search Results: Vertical layout with 2 columns
              let itemSize = NSCollectionLayoutSize(
                  widthDimension: .fractionalWidth(0.5),
                  heightDimension: .absolute(250) // Use an absolute height
              )
              let item = NSCollectionLayoutItem(layoutSize: itemSize)
              item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
              
              let groupSize = NSCollectionLayoutSize(
                  widthDimension: .fractionalWidth(1.0),
                  heightDimension: .absolute(250) // Match the item's height
              )
              let group = NSCollectionLayoutGroup.horizontal(
                  layoutSize: groupSize,
                  subitem: item,
                  count: 2 // Use subitem with count 2 for two columns
              )
              
              let section = NSCollectionLayoutSection(group: group)
              section.contentInsets = NSDirectionalEdgeInsets(
                  top: 0,
                  leading: 0,
                  bottom: 16,
                  trailing: 0
              )
              
              return section
          }
            if sectionIndex == 0 {
                // Layout for Category Cells
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .estimated(87),
                    heightDimension: .absolute(35)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .estimated(87),
                    heightDimension: .absolute(36)
                )
                
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize,
                    subitems: [item]
                )
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.interGroupSpacing = 8
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 0,
                    leading: 16,
                    bottom: 0,
                    trailing: 16
                )
                
                return section
                
            } else {
                // Layout for Product Cells or Loading Placeholders
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .absolute(150),
                    heightDimension: .absolute(220)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .estimated(150),
                    heightDimension: .absolute(240)
                )
                
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize,
                    repeatingSubitem: item,
                    count: 1
                )
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 0,
                    leading: 16,
                    bottom: 16,
                    trailing: 16
                )
                
                let headerSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(40)
                )
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: SectionHeaderViewModel.kind,
                    alignment: .topLeading
                )
                section.boundarySupplementaryItems = [sectionHeader]
                
                return section
            }
        }
        
        return layout
    }
    
    private func configureAppearance() {
        title = "Home"
    }
    
    private func setupNavigationVar() {
        // Initialize searchController
        searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search bikes"
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        navigationItem.searchController = searchController
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // Existing code for the cart button
        let cartButton = UIButton(type: .system)
        cartButton.setImage(UIImage(systemName: "cart.fill"), for: .normal)
        cartButton.tintColor = UIColor(hex: "F2F2F2")
        cartButton.addTarget(self, action: #selector(cartButtonTapped), for: .touchUpInside)
        
        // Add badge to cart button
        var badgeAppearance = BadgeAppearance()
        badgeAppearance.backgroundColor = .red
        badgeAppearance.textColor = .white
        badgeAppearance.font = ThemeFont.bold(ofSize: 12)
        badgeAppearance.distanceFromCenterX = 13
        badgeAppearance.distanceFromCenterY = -10
        cartButton.badge(text: "5", appearance: badgeAppearance)
        
        let cartBarButton = UIBarButtonItem(customView: cartButton)
        navigationItem.rightBarButtonItems = [cartBarButton]
      
      let filterButton = UIBarButtonItem(
             image: UIImage(systemName: "line.horizontal.3.decrease.circle"),
             style: .plain,
             target: self,
             action: #selector(filterButtonTapped)
         )
      filterButton.tintColor = ThemeColor.primary
         navigationItem.leftBarButtonItem = filterButton
    }
    
    @objc private func cartButtonTapped() {
        coordinator.showCartController()
    }
    
    func updateCartBadge(count: Int) {
        if let cartButton = navigationItem.rightBarButtonItems?.first?.customView as? UIButton {
            if count > 0 {
                cartButton.badge(text: "\(count)")
            } else {
                cartButton.badge(text: nil)
            }
        }
    }
    
    private func updateBadge() {
        service.fetchBike()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                    
                case .failure(let error):
                    print("Error fetching bike items: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] bike in
                self?.updateCartBadge(count: bike.count)
            }
            .store(in: &cancellables)
    }
  
  @objc private func handleFilterChange() {
         applyFilters()
     }
  
  @objc private func filterButtonTapped() {
          let filter = FilterViewController(categories: categories)
          filter.modalPresentationStyle = .pageSheet
          
          if let sheet = filter.sheetPresentationController {
              sheet.prefersGrabberVisible = true
              sheet.detents = [.large()]
              present(filter, animated: true)
          }
      }
  
  private func applyFilters() {
          let filterManager = FilterManager.shared
          
          // Filter the products based on selected filters
          let filteredCategories = categories.compactMap { category -> Category? in
              // Check if we should include this category
              if !filterManager.selectedCategories.isEmpty &&
                 !filterManager.selectedCategories.contains(category.categoryName) {
                  return nil
              }
              
              // Filter products within the category
              let filteredProducts = category.products.filter { product in
                  // Apply brand filter
                  if !filterManager.selectedBrands.isEmpty &&
                     !filterManager.selectedBrands.contains(product.brand) {
                      return false
                  }
                  
                  // Apply price filter
                  if product.price < filterManager.priceRange.min ||
                     product.price > filterManager.priceRange.max {
                      return false
                  }
                  
                  return true
              }
              
              // Sort the filtered products
              let sortedProducts: [Product]
              switch filterManager.sortBy {
              case .nameAsc:
                  sortedProducts = filteredProducts.sorted { $0.name < $1.name }
              case .nameDesc:
                  sortedProducts = filteredProducts.sorted { $0.name > $1.name }
              case .priceLowToHigh:
                  sortedProducts = filteredProducts.sorted { $0.price < $1.price }
              case .priceHighToLow:
                  sortedProducts = filteredProducts.sorted { $0.price > $1.price }
              }
              
              return Category(categoryName: category.categoryName, products: sortedProducts)
          }
          
          // Update the categories with filtered results
          self.categories = filteredCategories
          self.updateCollectionView()
      }

    
    private func showWelcomeNotification(with profile: UserProfile) {
        let styleName = "WelcomeStyle"
        NotificationPresenter.shared.addStyle(named: styleName) { style in
            style.backgroundStyle.backgroundColor = ThemeColor.primary
            style.textStyle.textColor = ThemeColor.cardFillColor
            style.textStyle.font = ThemeFont.bold(ofSize: 14)
            style.subtitleStyle.textColor = ThemeColor.cardFillColor
            style.subtitleStyle.font = ThemeFont.medium(ofSize: 12)
            style.progressBarStyle.barColor = ThemeColor.cardFillColor
            style.progressBarStyle.barHeight = 0.1
            return style
        }
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        let image = UIImage(systemName: "helmet.fill", withConfiguration: imageConfig)
        let imageView = UIImageView(image: image)
        imageView.tintColor = ThemeColor.cardFillColor
        
        let username = profile.email.components(separatedBy: "@").first ?? "User"
        
        NotificationPresenter.shared.present(
            "Welcome back, \(username)!",
            subtitle: "Ready to ride",
            styleName: styleName
        ) { presenter in
            presenter.displayLeftView(imageView)
            
            presenter.animateProgressBar(to: 1.0, duration: 2.0) { presenter in
                presenter.dismiss()
            }
        }
        
        NotificationPresenter.shared.displayProgressBar(at: 0.0)
    }
    
    @objc private func handlePaymentCompletion(_ notification: Notification) {
        // Handle payment completion
    }
    
    // MARK: - CellEventCoordinator
  
    func didSelectCell(viewModel: any CellViewModel) {
        if let categoryVM = viewModel as? CategoryCellViewModel {
            selectedCategory = categoryVM.category != "All" ? categoryVM.category : nil
            updateCollectionView()
        } else if let productVM = viewModel as? BikeProductCellViewModel {
            // Dismiss the search controller if active
            if searchController.isActive {
                searchController.dismiss(animated: true, completion: nil)
            }
            coordinator.showDetailViewController(for: productVM.product ?? Product(
                id: "PLACEHOLDER-001",
                name: "Loading...",
                description: "Loading product details...",
                images: ["placeholder_image"],
                price: 0,
                brand: "Loading...",
                quantity: 0
            ))
        }
    }
}

