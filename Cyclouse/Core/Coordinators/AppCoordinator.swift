//
//  AppCoordinator.swift
//  Cyclouse
//
//  Created by yoga arie on 05/09/24.
//

import UIKit
import Valet

// MARK: - App Coordinator
class AppCoordinator: Coordinator {
  
  // MARK: - Properties
  weak var parentCoordinator: Coordinator?
  var childCoordinators = [Coordinator]()
  var navigationController: UINavigationController
  private let valet = Valet.valet(with: Identifier(nonEmpty: "com.cyclouse.app")!, accessibility: .whenUnlocked)
   
  // MARK: - Initialization
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  // MARK: - Coordinator Methods
  func start() {
       if !TokenManager.shared.hasSeenOnboarding() {
           showOnboarding()
       } else if TokenManager.shared.isLoggedIn() {
           showMainTabbar()
       } else {
           showLogin()
       }
   }
   
  // MARK: - Navigation Methods
  func showOnboarding() {
    childCoordinators.removeAll()
     let onboardingCoordinator = OnboardingCoordinator(navigationController: navigationController)
     addChildCoordinator(onboardingCoordinator)
     onboardingCoordinator.delegate = self
     onboardingCoordinator.start()
     
    // TODO: - Consider extracting window setup to a separate method for reusability
     if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
        let window = windowScene.windows.first {
       window.rootViewController = navigationController
     }
   }
  
  func showMainTabbar() {
    let tabbarController = UITabBarController()
    let coordinator = TabbarCoordinator(tabBarController: tabbarController)
    addChildCoordinator(coordinator)
    coordinator.start()

  }
  
  // MARK: - Coordinator Lifecycle
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

// MARK: - OnboardingCoordinatorDelegate
extension AppCoordinator: OnboardingCoordinatorDelegate {
  func onboardingComplete() {
    if TokenManager.shared.isLoggedIn() {
      showMainTabbar()
    } else {
      showLogin()
    }
  }
}
