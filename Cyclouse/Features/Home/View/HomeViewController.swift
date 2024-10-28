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

class HomeViewController: UIViewController {
  
  var isLoading = true {
  didSet {
    updateCollectionView()
  }
}
  // Hardcoded list of categories
  let allCategories = ["All", "Full Bike", "Handlebar", "Saddle", "Pedal", "Seatpost", "Stem", "Crank", "Wheelset", "Frame", "Tires"]
  var selectedCategory: String? = nil

  var collectionView: UICollectionView!
  private var cancellable = Set<AnyCancellable>()
  var coordinator: HomeCoordinator
  private let service = DatabaseService.shared
  var driver: CollectionViewDriver?
  var services = BikeService()
  var cancellables = Set<AnyCancellable>()
  var categories: [Category] = []
  private let valet = Valet.valet(with: Identifier(nonEmpty: "com.yourapp.auth")!, accessibility: .whenUnlocked)
  
  
  
  
  private var searchController: UISearchController!
  
  init(coordinator: HomeCoordinator) {
    self.coordinator = coordinator
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = ThemeColor.background
    configureAppearance()
//    setupViews()
//    setupLayout()
    setupNavigationVar()
//    setupDatabaseObserver()
    updateBadge()
    loadUserProfile()
    
    
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
    collectionView.backgroundColor = .clear
    
    // Add to view hierarchy
    view.addSubview(collectionView)
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    ])
    
    // Initialize the driver
    driver = CollectionViewDriver(
      view: collectionView,
      viewModel: makeViewModel(),
      cellEventCoordinator: self
    )
    isLoading = true
      updateCollectionView()
      simulateLoading()
    
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    updateBadge()
  }
  
  private func simulateLoading() {
      DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
          self?.isLoading = false
          self?.fetchBikes()
      }
  }
  
  private func showWelcomeNotification(with profile: UserProfile) {
    // Create a custom style
    
    let styleName = "WelcomeStyle"
    NotificationPresenter.shared.addStyle(named: styleName) { style in
      style.backgroundStyle.backgroundColor = ThemeColor.primary
      style.textStyle.textColor = ThemeColor.cardFillColor
      style.textStyle.font = ThemeFont.bold(ofSize: 14)
      style.subtitleStyle.textColor = ThemeColor.cardFillColor
      style.subtitleStyle.font = ThemeFont.medium(ofSize: 12)
      style.progressBarStyle.barColor = ThemeColor.cardFillColor // Set progress bar color to light gray
      style.progressBarStyle.barHeight = 0.1
      return style
    }
    
    // Create the left view (game controller icon)
    let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
    let image = UIImage(systemName: "helmet.fill", withConfiguration: imageConfig)
    let imageView = UIImageView(image: image)
    imageView.tintColor =  ThemeColor.cardFillColor
    
    let username = profile.email.components(separatedBy: "@").first ?? "User"
    
    // Present the notification
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

     // or set an explicit percentage manually (without animation)
     NotificationPresenter.shared.displayProgressBar(at: 0.0)
    }
  
  
  private func loadUserProfile(){
    do {
      let profileData = try valet.object(forKey: "userProfile")
      let userProfile = try JSONDecoder().decode(UserProfile.self, from: profileData)
      showWelcomeNotification(with: userProfile)
    } catch {
      print("Failed to load user profile: \(error)")
    }
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
        //        self.productByCategory = Dictionary(uniqueKeysWithValues: self.categories.map { ($0.categoryName, $0.products) })
        // Update the collection view
        self.isLoading = false
        updateCollectionView()
      }
      .store(in: &cancellables)
  }

  
  private func updateCollectionView() {
    let viewModel = makeViewModel()
    driver?.update(viewModel: viewModel, animated: true)
  }

  private func makeViewModel() -> CollectionViewModel {
   var sections: [SectionViewModel] = []

   // **First Section: Categories**
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
       // **Create Multiple Placeholder Sections**

       // Let's simulate having 3 placeholder categories
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
       // **Subsequent Sections: Bike Products**

       // Filter categories based on selectedCategory
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

   return CollectionViewModel(
       id: "main_collection",
       sections: sections
   )
}




  
 private func makeLayout() -> UICollectionViewCompositionalLayout {
    let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex, environment) -> NSCollectionLayoutSection? in

        guard let self = self else { return nil }

        if sectionIndex == 0 {
            // **Layout for Category Cells**

            // Item Size - Use estimated width to adapt to content
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .estimated(87),  // Will adjust based on content
                heightDimension: .absolute(35)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)

            // Group Size - Use estimated width
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .estimated(87), // Match item estimated width
                heightDimension: .absolute(36)
            )

            // Create group that can contain multiple items
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )

            // Section Configuration
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.interGroupSpacing = 8 // Space between groups
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 0,
                leading: 16,
                bottom: 0,
                trailing: 16
            )

            return section

        } else {
            // **Layout for Product Cells or Loading Placeholders**

            // Item Size
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .absolute(150),
                heightDimension: .absolute(220)  // Adjusted height to match your design
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)

            // Group Size
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .estimated(150),
                heightDimension: .absolute(240)
            )

            // Create group that repeats items
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                repeatingSubitem: item,
                count: 1
            )

            // Section Configuration
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.interGroupSpacing = 10  // Space between groups
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 0,
                leading: 16,
                bottom: 16,
                trailing: 16
            )

            // Header for Product Sections (excluding the loading placeholder section)
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
  
  private func setupNavigationVar(){
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
    
    searchController = UISearchController(searchResultsController: nil)
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchBar.placeholder = "Search bikes"
    navigationItem.searchController = searchController
    definesPresentationContext = true
    navigationItem.hidesSearchBarWhenScrolling = false
  }
  
  @objc func cartButtonTapped() {
    print("Cart button tapped")
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
      .store(in: &cancellable)
  }
  
  
}
extension HomeViewController: CellEventCoordinator {
    func didSelectCell(viewModel: any CellViewModel) {
        if let categoryVM = viewModel as? CategoryCellViewModel {
            print("Selected Category: \(categoryVM.category)")
            selectedCategory = categoryVM.category != "All" ? categoryVM.category : nil
            // Update collection view
            updateCollectionView()
        } else if let productVM = viewModel as? BikeProductCellViewModel {
          coordinator.showDetailViewController(for: productVM.product ??       Product(
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



