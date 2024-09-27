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

class HomeViewController: UIViewController {
  
  private var viewModel: HomeViewModel!
  private var cancellable = Set<AnyCancellable>()
  var coordinator: HomeCoordinator
  
  private let cellSelectedSubject = PassthroughSubject<IndexPath, Never>()
  
  lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collection.dataSource = self
    collection.delegate = self
    collection.backgroundColor = .clear
    return collection
  }()
  
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
    configureAppearance()
    setupViews()
    setupLayout()
    setupNavigationVar()
    bindViewModel()
  }
  
  
  private func configureAppearance() {
    title = "Home"
    viewModel = HomeViewModel(service: BikeService())
    view.backgroundColor = ThemeColor.background
  }
  
  private func setupViews(){
    view.addSubview(collectionView)
    registerCells()
  }
  
  private func setupLayout() {
    collectionView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
  
  private func setupNavigationVar(){
    let cartButton = UIBarButtonItem(image: UIImage(systemName: "cart.fill"), style: .plain, target: self, action: #selector(cartButtonTapped))
    cartButton.tintColor = UIColor(hex: "F2F2F2")
    navigationItem.rightBarButtonItems = [cartButton]
    
    searchController = UISearchController(searchResultsController: nil)
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchBar.placeholder = "Search bikes"
    navigationItem.searchController = searchController
    definesPresentationContext = true
  }
  
  @objc func cartButtonTapped() {
    print("Cart button tapped")
    coordinator.showCartController()
  }
  
  
  private func registerCells(){
    collectionView.register(HorizontalViewCell.self, forCellWithReuseIdentifier: "HorizontalViewCell")
    collectionView.register(HeaderReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerCell")
  }
  
  private func bindViewModel() {
    viewModel.$sections
      .receive(on: RunLoop.main)
      .sink { [weak self] _ in
        self?.collectionView.reloadData()
      }
      .store(in: &cancellable)
    
//    cellSelectedSubject
//      .sink { [weak self] indexPath in
//        self?.handleCellSelection(at: indexPath, item: <#Any#>)
//      }
//      .store(in: &cancellable)
  }
  
  private func handleCellSelection(section: Int, item: Any) {
    let section = viewModel.sections[section]
    switch section.cellType {
    case .category:
      break
      
    case .cycleCard:
      if let products = item as? Product {
        coordinator.showDetailViewController(for: products)
      }
    }
  }
  
}


extension HomeViewController: UICollectionViewDataSource {
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return viewModel.sections.count
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return viewModel.sections[section].items.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = viewModel.configureCell(collectionView: collectionView, indexPath: indexPath)
    if let horizontalCell = cell as? HorizontalViewCell {
      horizontalCell.cellSelected
        .sink { [weak self] (selectedIndexPath, selectedItem) in
          self?.handleCellSelection(section: indexPath.section  , item: selectedItem)
        }
        .store(in: &cancellable)
    }
    return cell
  }
  
  
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    viewModel.sizeForItem(at: indexPath, viewWidth: self.view.frame.width)
  }
  
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    viewModel.insetForSection(at: section)
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerCell", for: indexPath) as! HeaderReusableView
    header.headerLabel.text = viewModel.sections[indexPath.section].header
    return header
  }
  
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    viewModel.sizeForHeader(in: section, collectionViewWidth: collectionView.frame.width)
  }
  
}


extension HomeViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    cellSelectedSubject.send(indexPath)
  }
}

