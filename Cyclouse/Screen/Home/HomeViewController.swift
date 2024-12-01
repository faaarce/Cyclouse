//
//  HomeViewController.swift
//  Cyclouse
//
//  Created by yoga arie on 05/09/24.
//
import SnapKit
import UIKit
import Combine

class HomeViewController: UIViewController {
  
  private var viewModel: HomeViewModel!
  private var cancellable = Set<AnyCancellable>()
  var coordinator: HomeCoordinator
  
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
  }
  
  
  private func configureAppearance() {
    title = "Home"
    viewModel = HomeViewModel(bikeData: loadBikeData())
    view.backgroundColor = ThemeColor.background
  }
  
  private func loadBikeData() -> [Bike] {
    return [
      Bike(name: "Fixie FullBike Jayjo", type: "Fullbike", price: 25000000, numberSold: 20),
      Bike(name: "Fixie FullBike Jayjo", type: "Fullbike", price: 25000000, numberSold: 20),
      Bike(name: "Fixie FullBike Jayjo", type: "Fullbike", price: 25000000, numberSold: 20),
      Bike(name: "Fixie FullBike Jayjo", type: "Fullbike", price: 25000000, numberSold: 20),
      Bike(name: "Fixie FullBike Jayjo", type: "Fullbike", price: 25000000, numberSold: 20),
      Bike(name: "Fixie FullBike Jayjo", type: "Fullbike", price: 25000000, numberSold: 20),
      Bike(name: "Fixie FullBike Jayjo", type: "Fullbike", price: 25000000, numberSold: 20),
      Bike(name: "Fixie FullBike Jayjo", type: "Fullbike", price: 25000000, numberSold: 20),
      Bike(name: "Fixie FullBike Jayjo", type: "Fullbike", price: 25000000, numberSold: 20),
      Bike(name: "Fixie FullBike Jayjo", type: "Fullbike", price: 25000000, numberSold: 20)
    ]
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
    coordinator.showDetailViewController()
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
    viewModel.configureCell(collectionView: collectionView, indexPath: indexPath)
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


