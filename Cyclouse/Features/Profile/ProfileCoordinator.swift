//
//  ProfileCoordinator.swift
//  Cyclouse
//
//  Created by yoga arie on 05/09/24.
//

import UIKit

class ProfileCoordinator: Coordinator, NavigationCoordinator {
  var childCoordinators: [any Coordinator] = []
  
  weak var parentCoordinator: (any Coordinator)?
  
  unowned var navigationController: UINavigationController
  
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  
  func start() {
    let vc = ProfileViewController(coordinator: self)
    navigationController.setViewControllers([vc], animated: true)
  }
  
  func showTransactionHistory(){
    let historyCoordinator = HistoryCoordinator(navigationController: navigationController)
    childCoordinators.append(historyCoordinator)
    historyCoordinator.parentCoordinator = self
    historyCoordinator.start()
  }
  
  func showPayment(){
    let paymentCoordinator = PaymentCoordinator(navigationController: navigationController)
    childCoordinators.append(paymentCoordinator)
    paymentCoordinator.parentCoordinator = self
    paymentCoordinator.start()
  }
  
  func logout() {
    didFinish()
    (parentCoordinator as? TabbarCoordinator)?.handleLogout()
  }

}


