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
  
  init(navigationController: UINavigationController, container: Container) {
    self.navigationController = navigationController
    self.container = container
  }
  
  func start() {
    let DetailOrderVC = DetailOrderViewController(coordinator: self)
    navigationController.pushViewController(DetailOrderVC, animated: true)
  }
  
  func didFinish() {
    parentCoordinator?.removeChildCoordinator(self)
  }
}
