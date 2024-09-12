//
//  TabbarCoordinator.swift
//  Cyclouse
//
//  Created by yoga arie on 05/09/24.
//

import UIKit

class TabbarCoordinator: Coordinator {
  var childCoordinators: [any Coordinator] = []
  
  weak var parentCoordinator: Coordinator?
  unowned var tabBarController: UITabBarController
  
  init(tabBarController: UITabBarController) {
    self.tabBarController = tabBarController
  }
  
  func start() {
    let homeNav = UINavigationController()
    let homeCoordinator = HomeCoordinator(navigationController: homeNav)
    addChildCoordinator(homeCoordinator)
    homeCoordinator.start()
    
    let profileNav = UINavigationController()
    let profileCoordinator = CartCoordinator(navigationController: profileNav)
    addChildCoordinator(profileCoordinator)
    profileCoordinator.start()
    
    let wishlistNav = UINavigationController()
    let wishlistCoordinator = WishlistCoordinator(navigationController: wishlistNav)
    addChildCoordinator(wishlistCoordinator)
    wishlistCoordinator.start()
    
    tabBarController.setViewControllers([
      homeNav,
      wishlistNav,
      profileNav
    ], animated: false)
    setupTabbar()
    startWithRoot(tabBarController)
    
    
  }
  
  private func setupTabbar() {
    guard let viewControllers = tabBarController.viewControllers else { return }
    
    viewControllers[0].tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: "home_icon_inactive"), selectedImage:  UIImage(named: "home_icon_active"))
    
    viewControllers[1].tabBarItem = UITabBarItem(title: "Cart", image: UIImage(systemName: "cart"), selectedImage: UIImage(systemName: "cart.fill"))
  
    viewControllers[2].tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "profile_icon_inactive"), selectedImage: UIImage(named: "profile_icon_active"))
    
  
    UITabBar.appearance().backgroundColor = ThemeColor.cardFillColor
    UITabBar.appearance().tintColor = ThemeColor.primary
    UITabBar.appearance().unselectedItemTintColor = ThemeColor.secondary
  }
  
  func gotoProfile() {
    tabBarController.selectedIndex = 3
  }
  
}
