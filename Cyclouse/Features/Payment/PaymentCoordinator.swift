//
//  PaymentCoordinator.swift
//  Cyclouse
//
//  Created by yoga arie on 13/10/24.
//

import Foundation
import UIKit
import Swinject

class PaymentCoordinator: Coordinator, NavigationCoordinator {
  var childCoordinators: [Coordinator] = []
  weak var parentCoordinator: Coordinator?
  var navigationController: UINavigationController
  private let paymentDetail: CheckoutData
  var container: Container
  
  init(navigationController: UINavigationController, paymentDetail: CheckoutData, container: Container) {
    self.navigationController = navigationController
    self.paymentDetail = paymentDetail
    self.container = container
  }
  
  func start() {
  
    let vc = PaymentViewController(coordinator: self, paymentDetail: paymentDetail)
    navigationController.pushViewController(vc, animated: true)
  }
  
  func didFinish(){
    parentCoordinator?.removeChildCoordinator(self)
  }
}
