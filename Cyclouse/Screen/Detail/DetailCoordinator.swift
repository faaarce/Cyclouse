//
//  DetailCoordinator.swift
//  Cyclouse
//
//  Created by yoga arie on 11/09/24.
//

import Foundation
import UIKit

class DetailCoordinator: Coordinator, NavigationCoordinator {
  var childCoordinators: [Coordinator] = []
  weak var parentCoordinator: Coordinator?
  var navigationController: UINavigationController
  
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  func start() {
    let detailVC = DetailViewController(coordinator: self)
    navigationController.pushViewController(detailVC, animated: true)
  }
  
  func didFinish(){
    parentCoordinator?.removeChildCoordinator(self)
  }
}
