//
//  DetailCoordinator.swift
//  Cyclouse
//
//  Created by yoga arie on 11/09/24.
//

import Foundation
import UIKit
import Hero
import Swinject

class DetailCoordinator: Coordinator, NavigationCoordinator {
  var childCoordinators: [Coordinator] = []
  weak var parentCoordinator: Coordinator?
  var navigationController: UINavigationController
  private let product: Product
  private let container: Container
  
  init(navigationController: UINavigationController, product: Product, container: Container ) {
    self.navigationController = navigationController
    self.product = product
    self.container = container
  }
  
  func start() {
    print("DEBUG: Coordinator showing detail view for product: \(product.name)")
    let viewModel = container.resolve(DetailViewModel.self, argument: product)!
    let detailVC = DetailViewController(coordinator: self, viewModel: viewModel)
    detailVC.hero.isEnabled = true
    detailVC.hidesBottomBarWhenPushed = true
    navigationController.hero.isEnabled = true
    navigationController.pushViewController(detailVC, animated: true)
  }
  
  func showCheckout(bikes: [BikeDatabase]){
    let checkoutCoordinator = container.resolve(
                CheckoutCoordinator.self,
                arguments: navigationController, bikes
            )!
    childCoordinators.append(checkoutCoordinator)
    checkoutCoordinator.parentCoordinator = self
    checkoutCoordinator.start()
  }
  
  func showCartController(){
    let cartCoordinator = container.resolve(CartCoordinator.self, argument: navigationController)!
    addChildCoordinator(cartCoordinator)
    cartCoordinator.parentCoordinator = self
    cartCoordinator.start()
  }
  
  func didFinish(){
    parentCoordinator?.removeChildCoordinator(self)
  }
}
