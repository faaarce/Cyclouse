//
//  PaymentCoordinator.swift
//  Cyclouse
//
//  Created by yoga arie on 13/10/24.
//

import Foundation
import UIKit

class PaymentCoordinator: Coordinator, NavigationCoordinator {
  var childCoordinators: [Coordinator] = []
  weak var parentCoordinator: Coordinator?
  var navigationController: UINavigationController
  
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  func start() {
//    let paymentVC = PaymentViewController(coordinator: self)
//    paymentVC.hidesBottomBarWhenPushed = true
//    navigationController.pushViewController(paymentVC, animated: true)
    
    let vc = PaymentViewController(coordinator: self)
    navigationController.setViewControllers([vc], animated: true)
  }
  
  func didFinish(){
    parentCoordinator?.removeChildCoordinator(self)
  }
}
