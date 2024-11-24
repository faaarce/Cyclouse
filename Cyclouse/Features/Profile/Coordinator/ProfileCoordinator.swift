//
//  ProfileCoordinator.swift
//  Cyclouse
//
//  Created by yoga arie on 05/09/24.
//
import Swinject
import UIKit

class ProfileCoordinator: Coordinator, NavigationCoordinator {
  var childCoordinators: [Coordinator] = []
  
  weak var parentCoordinator: Coordinator?
  private let container: Container
  unowned var navigationController: UINavigationController
  
  init(navigationController: UINavigationController, container: Container) {
    self.navigationController = navigationController
    self.container = container
  }
  
  
  func start() {
    let vc = ProfileViewController(coordinator: self)
    navigationController.setViewControllers([vc], animated: true)
  }
  
  func showTransactionHistory(){
    let historyCoordinator = container.resolve(HistoryCoordinator.self, argument: navigationController)!
    childCoordinators.append(historyCoordinator)
    historyCoordinator.parentCoordinator = self
    historyCoordinator.start()
  }
  
  
  func logout() {
    didFinish()
    (parentCoordinator as? TabbarCoordinator)?.handleLogout()
  }
  
}


