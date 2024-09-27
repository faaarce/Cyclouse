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
  let product: Product
  
  init(navigationController: UINavigationController, product: Product ) {
    self.navigationController = navigationController
    self.product = product
  }
  
  func start() {
    let detailVC = DetailViewController(coordinator: self, product: product)
    detailVC.hidesBottomBarWhenPushed = true
    navigationController.pushViewController(detailVC, animated: true)
  }
  
  func didFinish(){
    parentCoordinator?.removeChildCoordinator(self)
  }
}
