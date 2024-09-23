//
//  HomeCoordinator.swift
//  Cyclouse
//
//  Created by yoga arie on 05/09/24.
//

import UIKit

class HomeCoordinator: Coordinator, NavigationCoordinator {
  var childCoordinators: [any Coordinator] = []
  
  weak var parentCoordinator: (any Coordinator)?
  unowned var navigationController: UINavigationController
  
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  func start() {
    let vc = HomeViewController(coordinator: self)
   
    navigationController.setViewControllers([vc], animated: true)
  }
  
  func showDetailViewController() {
    let detailCoordinator = DetailCoordinator(navigationController: navigationController)
    addChildCoordinator(detailCoordinator)
    detailCoordinator.parentCoordinator = self
    detailCoordinator.start()
  }
  
  func showCartController(){
    let cartCoordinator = CartCoordinator(navigationController: navigationController)
    addChildCoordinator(cartCoordinator)
    cartCoordinator.parentCoordinator = self
    cartCoordinator.start()
  }
}
