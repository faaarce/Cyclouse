//
//  HomeCoordinator.swift
//  Cyclouse
//
//  Created by yoga arie on 05/09/24.
//
import Swinject
import UIKit

class HomeCoordinator: Coordinator, NavigationCoordinator {
  var childCoordinators: [Coordinator] = []
  
  weak var parentCoordinator:  Coordinator?
  unowned var navigationController: UINavigationController
  private let container: Container
  
  init(navigationController: UINavigationController, container: Container) {
    self.navigationController = navigationController
    self.container = container
  }
  
  func start() {
    let vc = HomeViewController(coordinator: self)
    
    navigationController.setViewControllers([vc], animated: true)
  }
  
  func showDetailViewController(for product: Product) {
    let detailCoordinator = container.resolve(
      DetailCoordinator.self,
      arguments: navigationController, product
    )!
    addChildCoordinator(detailCoordinator)
    detailCoordinator.parentCoordinator = self
    detailCoordinator.start()
  }
  
  func showCartController(){
    let cartCoordinator = container.resolve(CartCoordinator.self, argument: navigationController)!
    addChildCoordinator(cartCoordinator)
    cartCoordinator.parentCoordinator = self
    cartCoordinator.start()
  }
}
