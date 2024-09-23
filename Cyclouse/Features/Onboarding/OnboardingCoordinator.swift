//
//  OnboardingCoordinator.swift
//  Cyclouse
//
//  Created by yoga arie on 06/09/24.
//

import UIKit

class OnboardingCoordinator: Coordinator, NavigationCoordinator {
  var childCoordinators: [any Coordinator] = []
  
  weak var parentCoordinator: (any Coordinator)?
  
  unowned var navigationController: UINavigationController
  
  
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  func start() {
    let vc = OnboardingViewController(coordinator: self)
    navigationController.pushViewController(vc, animated: true)
  }
  
  
  
  
}
