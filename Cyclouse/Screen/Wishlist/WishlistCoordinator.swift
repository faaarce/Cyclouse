//
//  WishlistCoordinator.swift
//  Cyclouse
//
//  Created by yoga arie on 06/09/24.
//

import UIKit

class WishlistCoordinator: Coordinator, NavigationCoordinator {
  var childCoordinators: [any Coordinator] = []
  
  weak var parentCoordinator: (any Coordinator)?
  unowned var navigationController: UINavigationController
  
  init(navigationController: UINavigationController){
    self.navigationController = navigationController
  }
  
  func start() {
    let vc = WishlistViewController(coordinator: self)
    navigationController.setViewControllers([vc], animated: true)
  }
  
}
