//
//  DetailOrderCoordinator.swift
//  Cyclouse
//
//  Created by yoga arie on 26/11/24.
//

import Foundation
import Swinject
import UIKit

class DetailOrderCoordinator: Coordinator, NavigationCoordinator {
  var childCoordinators: [Coordinator] = []
  weak var parentCoordinator: Coordinator?
  var navigationController: UINavigationController
  private let container: Container
  private let orderData: OrderHistory
  
  init(navigationController: UINavigationController, container: Container, orderData: OrderHistory) {
    self.navigationController = navigationController
    self.container = container
    self.orderData = orderData
  }
  
  func start() {
    let DetailOrderVC = DetailOrderViewController(coordinator: self, orderData: orderData)
    navigationController.pushViewController(DetailOrderVC, animated: true)
  }
  
  func didFinish() {
    parentCoordinator?.removeChildCoordinator(self)
  }
}
