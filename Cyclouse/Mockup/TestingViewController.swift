////
////  TestingViewController.swift
////  Cyclouse
////
////  Created by yoga arie on 21/10/24.
////
//
//
//import UIKit
//import Combine
//import ReactiveCollectionsKit
//
//class TestingViewController: UIViewController {
//    enum Section: Hashable {
//        case category(String)
//    }
//    var coordinator: TestingCoordinator
//    var collectionView: UICollectionView!
//    var dataSource: UICollectionViewDiffableDataSource<Section, Product>!
//    var bikeData: BikeDataResponse?
//    var cancellables = Set<AnyCancellable>()
//    let service = BikeService() // Replace with your actual service instance
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//      view.backgroundColor = ThemeColor.background
//
//        configureCollectionView()
//        configureDataSource()
//        fetchBikes()
//    }
//  
//  init(coordinator: TestingCoordinator) {
//    self.coordinator = coordinator
//    super.init(nibName: nil, bundle: nil)
//  }
//  
//  required init?(coder: NSCoder) {
//    fatalError("init(coder:) has not been implemented")
//  }
//    
//    func configureCollectionView() {
//      let layout = createLayout()
//        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        collectionView.delegate = self
//      collectionView.backgroundColor = .clear
//        collectionView.register(BikeProductViewCell.self, forCellWithReuseIdentifier: "BikeProductViewCell")
//        collectionView.register(HeaderReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerCell")
//
//        view.addSubview(collectionView)
//
//        // Add constraints
//        NSLayoutConstraint.activate([
//            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
//            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
//    }
//    
//  func createLayout() -> UICollectionViewLayout {
//         return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
//             // Item size and layout
//             let itemSize = NSCollectionLayoutSize(
//                 widthDimension: .absolute(150),
//                 heightDimension: .absolute(220)
//             )
//             let item = NSCollectionLayoutItem(layoutSize: itemSize)
//             item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
//
//             // Group size and layout
//             let groupSize = NSCollectionLayoutSize(
//                 widthDimension: .fractionalWidth(1.0),
//                 heightDimension: .absolute(220 + 10) // Item height + vertical insets
//             )
//             let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
//             group.interItemSpacing = .fixed(10)
//
//             // Section
//             let section = NSCollectionLayoutSection(group: group)
//             section.interGroupSpacing = 10
//             section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20)
//
//             // Header size and layout
//             let headerSize = NSCollectionLayoutSize(
//                 widthDimension: .fractionalWidth(1.0),
//                 heightDimension: .absolute(44)
//             )
//             let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
//                 layoutSize: headerSize,
//                 elementKind: UICollectionView.elementKindSectionHeader,
//                 alignment: .top
//             )
//             section.boundarySupplementaryItems = [sectionHeader]
//             return section
//         }
//     }
//    
//    func configureDataSource() {
//        dataSource = UICollectionViewDiffableDataSource<Section, Product>(collectionView: collectionView) { (collectionView, indexPath, product) -> UICollectionViewCell? in
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BikeProductViewCell", for: indexPath) as! BikeProductViewCell
//            cell.configure(with: product)
//            return cell
//        }
//        
//        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) in
//            guard kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }
//            let headerView = collectionView.dequeueReusableSupplementaryView(
//                ofKind: kind,
//                withReuseIdentifier: "headerCell",
//                for: indexPath
//            ) as! HeaderReusableView
//            let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
//            if case let .category(categoryName) = section {
//              headerView.headerLabel.text = categoryName
//            }
//            return headerView
//        }
//    }
//    
//    func fetchBikes() {
//        service.getBikes()
//            .receive(on: DispatchQueue.main)
//            .sink { completion in
//                if case let .failure(error) = completion {
//                    print("Error fetching bikes: \(error)")
//                }
//            } receiveValue: { [weak self] bikeDataResponse in
//              self?.processBikeData(bikeDataResponse.value)
//            }
//            .store(in: &cancellables)
//    }
//    
//  func processBikeData(_ bikeDataResponse: BikeDataResponse) {
//      print("Received bike data: \(bikeDataResponse)")
//      self.bikeData = bikeDataResponse
//      applySnapshot()
//  }
//    
//    func applySnapshot() {
//        guard let bikeData = bikeData else { return }
//        var snapshot = NSDiffableDataSourceSnapshot<Section, Product>()
//        
//        for category in bikeData.bikes.categories {
//            let section = Section.category(category.categoryName)
//            snapshot.appendSections([section])
//            snapshot.appendItems(category.products, toSection: section)
//        }
//        
//        dataSource.apply(snapshot, animatingDifferences: true)
//    }
//}
//
//extension TestingViewController: UICollectionViewDelegate {
//    // Implement delegate methods if needed
//}
//
