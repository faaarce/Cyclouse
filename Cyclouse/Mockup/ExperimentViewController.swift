import UIKit
import ReactiveCollectionsKit
import SnapKit
import Combine
import EasyNotificationBadge


class MyViewController: UIViewController {
  var collectionView: UICollectionView!
  var driver: CollectionViewDriver?
  var service = BikeService()
  var cancellables = Set<AnyCancellable>()
  private var searchController: UISearchController!
  var categories: [Category] = []
  //  var productByCategory: [String: [Product]] = [:]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = ThemeColor.background
    
    // Initialize the collection view with the custom layout
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
    
    fetchBikes()
    setupNavigationBar()
  }
  
  private func setupNavigationBar(){
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
  }
  
  @objc func cartButtonTapped() {
    print("Cart button tapped")
//    coordinator.showCartController()
  }
  
  private func fetchBikes() {
    service.getBikes()
      .receive(on: DispatchQueue.main)
      .sink { completion in
        switch completion {
        case .finished:
          break
          
        case .failure(let error):
          print("Error fetching bikes: \(error)")
        }
      } receiveValue: { [weak self] bikeDataResponse in
        guard let self = self else { return }
        self.categories = bikeDataResponse.value.bikes.categories
        //        self.productByCategory = Dictionary(uniqueKeysWithValues: self.categories.map { ($0.categoryName, $0.products) })
        // Update the collection view
        updateCollectionView()
      }
      .store(in: &cancellables)
  }
  
  private func updateCollectionView() {
    let viewModel = makeViewModel()
    driver?.update(viewModel: viewModel, animated: true)
  }
  
  private func makeLayout() -> UICollectionViewCompositionalLayout {
      let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex, environment) -> NSCollectionLayoutSection? in

          // Common Section Insets
          let sectionInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
          
          if sectionIndex == 0 {
              // **Section 0: Categories (Horizontal Scrolling)**

              // Item Size
              let itemSize = NSCollectionLayoutSize(
                  widthDimension: .estimated(80),
                  heightDimension: .absolute(36)
              )
              let item = NSCollectionLayoutItem(layoutSize: itemSize)
              // Add gaps between items using contentInsets
              item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
              
              // Group Size
              let groupSize = NSCollectionLayoutSize(
                  widthDimension: .estimated(80),
                  heightDimension: .absolute(36)
              )
              let group = NSCollectionLayoutGroup.horizontal(
                  layoutSize: groupSize,
                  subitems: [item]
              )
              // Optionally, you can adjust interItemSpacing instead of item.contentInsets
              // group.interItemSpacing = .fixed(10)
              
              // Section Configuration
              let section = NSCollectionLayoutSection(group: group)
              section.orthogonalScrollingBehavior = .continuous
              section.contentInsets = sectionInsets
              
              return section
              
          } else {
              // **Sections 1...N: Bike Product Cells (Horizontal Scrolling)**

              // Item Size
              let itemSize = NSCollectionLayoutSize(
                  widthDimension: .absolute(150),
                  heightDimension: .absolute(240)
              )
              let item = NSCollectionLayoutItem(layoutSize: itemSize)
              // Add gaps between items using contentInsets
              item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
              
              // Group Size
              let groupSize = NSCollectionLayoutSize(
                  widthDimension: .estimated(150),
                  heightDimension: .absolute(240)
              )
              let group = NSCollectionLayoutGroup.horizontal(
                  layoutSize: groupSize,
                  subitems: [item]
              )
              // Optionally, you can adjust interItemSpacing instead of item.contentInsets
              // group.interItemSpacing = .fixed(10)
              
              // Section Configuration
              let section = NSCollectionLayoutSection(group: group)
              section.orthogonalScrollingBehavior = .continuous
              section.contentInsets = sectionInsets
              
              // Header
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

  private func makeViewModel() -> CollectionViewModel {
      var sections: [SectionViewModel] = []

      // **First Section: Categories**
      let categoryCellViewModels = categories.map {
          CategoryCellViewModel(category: $0.categoryName).eraseToAnyViewModel()
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

      // **Subsequent Sections: Bike Products**
      for category in categories {
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

      return CollectionViewModel(
          id: "main_collection",
          sections: sections
      )
  }

  
  }

// MARK: - CellEventCoordinator

extension MyViewController: CellEventCoordinator {
  func didSelectCell(viewModel: any CellViewModel) {
          if let categoryVM = viewModel as? CategoryCellViewModel {
              print("Selected Category: \(categoryVM.category)")
              // Handle category selection
          } else if let productVM = viewModel as? BikeProductCellViewModel {
              print("Selected Product: \(productVM.product.name)")
              print("Product ID: \(productVM.product.id)")
              // Navigate to product detail, etc.
          }
      }
    }

//extension MyViewController: CellEventCoordinator {
//  func didSelectCell(viewModel: any CellViewModel) {
//    if let collectionViewModel = driver?.viewModel {
//      // Find section and cell indices
//      for (sectionIndex, section) in collectionViewModel.sections.enumerated() {
//        if let cellIndex = section.cells.firstIndex(where: { $0.id == viewModel.id }) {
//          // Get the selected cell details
//          if let experimentVM = viewModel as? ExperimentCellViewModel {
//            print("🔹 Selection Details:")
//            print("📍 Section: \(sectionIndex + 1)")
//            print("📍 Item: \(cellIndex + 1)")
//            print("📍 Title: \(experimentVM.title)")
//            print("📍 ID: \(experimentVM.id)")
//          }
//          return
//        }
//      }
//    }
//  }
//}

struct SectionHeaderViewModel: SupplementaryHeaderViewModel {
  typealias ViewType = UICollectionReusableView
  let id: UniqueIdentifier
  let title: String
  
  func configure(view: UICollectionReusableView) {
    view.subviews.forEach { $0.removeFromSuperview() }
    
    let label = UILabel()
    label.text = title
    label.font = UIFont.boldSystemFont(ofSize: 18)
    label.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(label)
    
    NSLayoutConstraint.activate([
      label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
  }
}



// MARK: - SupplementaryViewModel Conformance

extension SectionHeaderViewModel {
  static let kind = UICollectionView.elementKindSectionHeader
  
  var registration: ViewRegistration {
    return ViewRegistration(
      reuseIdentifier: "SectionHeader",
      viewType: .supplementary(kind: Self.kind),
      method: .viewClass(ReusableSectionHeaderView.self)
    )
  }
}

// Custom reusable view for the header
class ReusableSectionHeaderView: UICollectionReusableView {
  override init(frame: CGRect) {
    super.init(frame: frame)
    // Additional setup if needed
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

struct Item: Hashable {
  let id: UUID
  let title: String
}
