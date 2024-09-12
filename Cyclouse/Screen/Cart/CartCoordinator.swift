//
//  CartCoordinator.swift
//  Cyclouse
//
//  Created by yoga arie on 12/09/24.
//

import Foundation
import UIKit

class CartCoordinator: Coordinator, NavigationCoordinator {
  var childCoordinators: [any Coordinator] = []
  
  weak var parentCoordinator: (any Coordinator)?
  unowned var navigationController: UINavigationController
  
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  func start() {
    let vc = CartViewController(coordinator: self)
    navigationController.setViewControllers([vc], animated: true)
  }
}

