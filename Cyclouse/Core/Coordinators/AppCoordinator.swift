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
    showMainTabbar()
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
    
    navigationController.setViewControllers([tabbarController], animated: true)
    childCoordinators.removeAll { $0 is SignInCoordinator }
  }
  
  func coordinatorDidFinish(_ coordinator: Coordinator) {
    if coordinator is TabbarCoordinator {
      showLogin()
    }
  }
  
  func showLogin() {
    childCoordinators.removeAll()
    let signInCoordinator = SignInCoordinator(navigationController: navigationController)
    addChildCoordinator(signInCoordinator)
    signInCoordinator.start()
    
    // Ensure we're setting the root view controller of the window
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let window = windowScene.windows.first {
      window.rootViewController = navigationController
    }
  }
  
  func handleLogout() {
    showLogin()
  }
  
}
