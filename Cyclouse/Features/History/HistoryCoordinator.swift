//
//  HistoryCoordinator.swift
//  Cyclouse
//
//  Created by yoga arie on 16/09/24.
//
import Swinject
import Foundation
import UIKit

class HistoryCoordinator: Coordinator, NavigationCoordinator {
  var childCoordinators: [Coordinator] = []
  weak var parentCoordinator: Coordinator?
  var navigationController: UINavigationController
  private let container: Container
  
  init(navigationController: UINavigationController, container: Container) {
    self.navigationController = navigationController
    self.container = container
  }
  
  func start() {
    let historyVC = HistoryViewController(coordinator: self)
    historyVC.hidesBottomBarWhenPushed = true
    navigationController.pushViewController(historyVC, animated: true)
  }
  
  func didFinish(){
    parentCoordinator?.removeChildCoordinator(self)
  }
}
