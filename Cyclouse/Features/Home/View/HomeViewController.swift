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

class HomeViewController: UIViewController {
  
  private var viewModel: HomeViewModel!
  private var cancellable = Set<AnyCancellable>()
  var coordinator: HomeCoordinator
  private let service = DatabaseService.shared
  
  private let cellSelectedSubject = PassthroughSubject<IndexPath, Never>()
  
  private let valet = Valet.valet(with: Identifier(nonEmpty: "com.yourapp.auth")!, accessibility: .whenUnlocked)
  
  
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
    setupDatabaseObserver()
    updateBadge()
    loadUserProfile()
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    updateBadge()
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
  
  private func setupDatabaseObserver() {
    service.databaseUpdated
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _ in
        self?.updateBadge()
      }
      .store(in: &cancellable)
    
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
  
  private func handleCellSelection(section: Int, item: Any) {
    let section = viewModel.sections[section]
    switch section.cellType {
    case .category:
      if let category = item as? String {
        viewModel.filterProducts(by: category)
        collectionView.reloadData()
      }
      
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
          print("test homeviewmodel")
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


//extension HomeViewController: UICollectionViewDelegate {
//  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//    cellSelectedSubject.send(indexPath)
//  }
//}

