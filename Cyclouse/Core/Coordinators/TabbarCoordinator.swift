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
  
  // MARK: - Private Properties
  private let container: Container
  private var tabBarController: TabBarController
  private let service = DatabaseService.shared
  
  // MARK: - Initialization
  init(tabBarController: UITabBarController, container: Container) {
    self.tabBarController = TabBarController()
    self.container = container
  }
  
  
  // MARK: -  Methods
  func start() {
    setupViewControllers()
    startWithRoot(tabBarController)
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
    
    // Home Tab
    viewControllers[0].tabBarItem = UITabBarItem(
      title: "Home",
      image: UIImage(named: "home_icon_inactive")?
        .withRenderingMode(.alwaysOriginal),
      selectedImage: UIImage(named: "home_icon_active")?
        .withRenderingMode(.alwaysTemplate)
    )
    
    // Profile Tab
    viewControllers[1].tabBarItem = UITabBarItem(
      title: "Profile",
      image: UIImage(named: "profile_icon_inactive")?
        .withRenderingMode(.alwaysOriginal),
      selectedImage: UIImage(named: "profile_icon_active")?
        .withRenderingMode(.alwaysTemplate)
    )
    
  }
  
  
  func handleLogout() {
    childCoordinators.forEach { $0.didFinish() }
    childCoordinators.removeAll()
    didFinish()
    if let appCoordinator = parentCoordinator as? AppCoordinator {
      appCoordinator.handleLogout()
    }
  }
  
  
}
