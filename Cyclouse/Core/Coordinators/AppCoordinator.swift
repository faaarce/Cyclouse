//
//  AppCoordinator.swift
//  Cyclouse
//
//  Created by yoga arie on 05/09/24.
//

import UIKit
import Valet
import Swinject

// MARK: - App Coordinator
class AppCoordinator: Coordinator {
  
  // MARK: - Properties
  weak var parentCoordinator: Coordinator?
  var childCoordinators = [Coordinator]()
  var navigationController: UINavigationController
  private let container: Container
  private let valet = Valet.valet(with: Identifier(nonEmpty: "com.cyclouse.app")!, accessibility: .whenUnlocked)
   
  // MARK: - Initialization
  init(navigationController: UINavigationController, container: Container) {
    self.navigationController = navigationController
    self.container = container
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
     
    startWithRoot(navigationController)
   }
  
  
  
  func showMainTabbar() {
    let tabbarController = UITabBarController()
    let coordinator = container.resolve(TabbarCoordinator.self, argument: tabbarController)!
    addChildCoordinator(coordinator)
    coordinator.start()

  }
  

  
  func showLogin() {
    childCoordinators.removeAll()
    let signInCoordinator = container.resolve(SignInCoordinator.self, argument: navigationController)!
    addChildCoordinator(signInCoordinator)
    signInCoordinator.start()
    
    startWithRoot(navigationController)
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
