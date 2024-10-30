//
//  CheckoutCoordinator.swift
//  Cyclouse
//
//  Created by yoga arie on 29/10/24.
//

import Foundation
import UIKit


class CheckoutCoordinator: Coordinator, NavigationCoordinator {
  var childCoordinators: [any Coordinator] = []
  
  weak var parentCoordinator: (any Coordinator)?
  
  unowned var navigationController: UINavigationController
  
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  
  func start() {
    let vc = CheckoutViewController(coordinator: self)
    navigationController.setViewControllers([vc], animated: true)
  }
  
}
