//
//  TestingCoordinator.swift
//  Cyclouse
//
//  Created by yoga arie on 21/10/24.
//

import Foundation
import UIKit

class TestingCoordinator: Coordinator, NavigationCoordinator {
  var childCoordinators: [any Coordinator] = []
  
  weak var parentCoordinator: (any Coordinator)?
  unowned var navigationController: UINavigationController
  
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  func start() {
    let vc = TestingViewController(coordinator: self)
   
    navigationController.setViewControllers([vc], animated: true)
  }
  
  func showDetailViewController(for product: Product) {
    let detailCoordinator = DetailCoordinator(navigationController: navigationController, product: product)
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
