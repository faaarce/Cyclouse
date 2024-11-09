//
//  CartCoordinator.swift
//  Cyclouse
//
//  Created by yoga arie on 12/09/24.
//

import Foundation
import UIKit
import Swinject

class CartCoordinator: Coordinator, NavigationCoordinator {
  var childCoordinators: [any Coordinator] = []
  var container: Container
  weak var parentCoordinator: (any Coordinator)?
  unowned var navigationController: UINavigationController
  
  init(navigationController: UINavigationController, container: Container) {
    self.navigationController = navigationController
    self.container = container
  }
  
  func start() {
    let vc = CartViewController(coordinator: self)
    vc.hidesBottomBarWhenPushed = true
    navigationController.pushViewController(vc, animated: true)
  }
  
  
  
  func showCheckout(bikes: [BikeV2]){
    let checkoutCoordinator = container.resolve(
                CheckoutCoordinator.self,
                arguments: navigationController, bikes
            )!
    childCoordinators.append(checkoutCoordinator)
    checkoutCoordinator.parentCoordinator = self
    checkoutCoordinator.start()
  }
  
  func didFinish() {
    parentCoordinator?.removeChildCoordinator(self)
  }
}

