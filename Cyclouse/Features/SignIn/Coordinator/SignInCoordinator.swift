//
//  SignInCoordinator.swift
//  Cyclouse
//
//  Created by yoga arie on 05/09/24.
//

import UIKit

class SignInCoordinator: Coordinator, NavigationCoordinator {
  var childCoordinators: [any Coordinator] = []
  
  weak var parentCoordinator: (any Coordinator)?
  unowned var navigationController: UINavigationController
  
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  func start() {
    let vc = SignInViewController(coordinator: self)
    navigationController.setViewControllers([vc], animated: true)
  }
  
  func didFinishSign() {
    (parentCoordinator as? AppCoordinator)?.showMainTabbar()
  }
}

