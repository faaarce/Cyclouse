//
//  TabbarCoordinator.swift
//  Cyclouse
//
//  Created by yoga arie on 05/09/24.
//

import UIKit
import Combine
import Swinject

class TabbarCoordinator: Coordinator {
  
  // MARK: - Properties
  var childCoordinators: [Coordinator] = []
  weak var parentCoordinator: Coordinator?
  private let container: Container
  private var tabBarController: TabBarController
//  private var cancellables = Set<AnyCancellable>()
  private let service = DatabaseService.shared
//  private var itemCount: Int = 0 {
//    didSet {
//      updateCartBadge()
//    }
//  }
  
  init(tabBarController: UITabBarController, container: Container) {
    self.tabBarController = TabBarController()
    self.container = container
  }
  
  func start() {
    setupViewControllers()
    startWithRoot(tabBarController)
//    setupDatabaseObserver()
  }
  
  func setupViewControllers() {
    let homeNav = UINavigationController()
    let homeCoordinator = container.resolve(HomeCoordinator.self, argument: homeNav)!
    addChildCoordinator(homeCoordinator)
    homeCoordinator.start()
    
    let profileNav = UINavigationController()
    let profileCoordinator = container.resolve(ProfileCoordinator.self, argument: profileNav)!
    addChildCoordinator(profileCoordinator)
    profileCoordinator.start()
    
    
    tabBarController.setViewControllers([
      homeNav,
      profileNav
    ], animated: false)
    setupTabBarItems()
  }
  
  
  
  private func setupTabBarItems() {
    guard let viewControllers = tabBarController.viewControllers else { return }
    
    viewControllers[0].tabBarItem = UITabBarItem(
         title: "Home",
         image: UIImage(named: "home_icon_inactive")?
             .withRenderingMode(.alwaysOriginal),  // Changed to alwaysOriginal
         selectedImage: UIImage(named: "home_icon_active")?
             .withRenderingMode(.alwaysTemplate)
     )
     
     viewControllers[1].tabBarItem = UITabBarItem(
         title: "Profile",
         image: UIImage(named: "profile_icon_inactive")?
             .withRenderingMode(.alwaysOriginal),  // Changed to alwaysOriginal
         selectedImage: UIImage(named: "profile_icon_active")?
             .withRenderingMode(.alwaysTemplate)
     )
     
    // Important: Set tags for wave animation
//         viewControllers.enumerated().forEach { $0.element.tabBarItem.tag = $0.offset + 1 }
  }
  
//  private func setupDatabaseObserver() {
//    service.databaseUpdated
//      .receive(on: DispatchQueue.main)
//      .sink { [weak self] _ in
//        self?.updateCartCount()
//      }
//      .store(in: &cancellables)
//    updateCartCount()
//  }
//  
//  private func updateCartCount() {
//    service.fetchBike()
//      .receive(on: DispatchQueue.main)
//      .sink { completion in
//        switch completion {
//        case .finished:
//          break
//          
//        case .failure(let error):
//          print("Error fetching bike items: \(error.localizedDescription)")
//        }
//      } receiveValue: { [weak self] bike in
//        self?.itemCount = bike.count
//      }
//      .store(in: &cancellables)
//  }
//  
//  private func updateCartBadge(){
//    if let cartTab = tabBarController.viewControllers?[0].tabBarItem {
//      cartTab.badgeValue = itemCount > 0 ? "\(itemCount)" : nil
//    }
//  }
  
  
  func handleLogout() {
    childCoordinators.forEach { $0.didFinish() }
    childCoordinators.removeAll()
    didFinish()
    if let appCoordinator = parentCoordinator as? AppCoordinator {
      appCoordinator.handleLogout()
    }
  }
//  
//  deinit {
//    cancellables.removeAll()
//  }
//  
  
}
