//
//  CheckoutCoordinator.swift
//  Cyclouse
//
//  Created by yoga arie on 29/10/24.
//

import Foundation
import UIKit
import Swinject

class CheckoutCoordinator: Coordinator, NavigationCoordinator {
  var childCoordinators: [any Coordinator] = []
  
  weak var parentCoordinator: (any Coordinator)?
  var container: Container
  unowned var navigationController: UINavigationController
  private let bike: [BikeDatabase]
  
  init(navigationController: UINavigationController, container: Container, bike: [BikeDatabase]) {
    self.navigationController = navigationController
    self.container = container
    self.bike = bike
  }
  
  func start() {
    let vc = CheckoutViewController(coordinator: self, bike: bike)
    vc.hidesBottomBarWhenPushed = true
    navigationController.pushViewController(vc, animated: true)
  }
  
  func didFinish() {
    parentCoordinator?.removeChildCoordinator(self)
  }
  
  func showPayment(_ checkoutData: CheckoutData) {
    let paymentCoordinator = container.resolve(PaymentCoordinator.self, arguments: navigationController, checkoutData)!
    childCoordinators.append(paymentCoordinator)
    paymentCoordinator.parentCoordinator = self
    paymentCoordinator.start()
  }
  
}
