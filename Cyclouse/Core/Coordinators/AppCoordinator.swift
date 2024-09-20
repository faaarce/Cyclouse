//
//  AppCoordinator.swift
//  Cyclouse
//
//  Created by yoga arie on 05/09/24.
//

import UIKit

class AppCoordinator: Coordinator {
  
  weak var parentCoordinator: Coordinator?
  var childCoordinators = [Coordinator]()
  var navigationController: UINavigationController
  
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  func start() {
    showOnboarding()
  }
  
  func showLogin() {
    let nav = UINavigationController()
    let coordinator = HomeCoordinator(navigationController: nav)
    addChildCoordinator(coordinator)
    coordinator.start()
  }
  
  func showOnboarding() {
    /*
    let onboardingCoordinator = OnboardingCoordinator(navigationController: navigationController)
    addChildCoordinator(onboardingCoordinator)
    onboardingCoordinator.start()*/
    
    let login = SignInCoordinator(navigationController: navigationController)
    addChildCoordinator(login)
    login.start()
  }
  
  func showMainTabbar() {
    let tabbarController = UITabBarController()
    let coordinator = TabbarCoordinator(tabBarController: tabbarController)
    addChildCoordinator(coordinator)
    coordinator.start()
  }
  
  
  
}
