//
//  SignUpCoordinator.swift
//  Cyclouse
//
//  Created by yoga arie on 20/09/24.
//

import UIKit

class SignUpCoordinator: Coordinator,
                         NavigationCoordinator {
  var childCoordinators: [Coordinator] = []
  weak var parentCoordinator: Coordinator?
  var navigationController: UINavigationController
  
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  func start() {
    let vc = SignUpViewController(coordinator: self)
    navigationController.pushViewController(vc, animated: true)
  }
  
  func didFinish() {
    parentCoordinator?.removeChildCoordinator(self)
  }
}

