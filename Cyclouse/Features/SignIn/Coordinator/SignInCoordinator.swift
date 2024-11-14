//
//  SignInCoordinator.swift
//  Cyclouse
//
//  Created by yoga arie on 05/09/24.
//
import Swinject
import UIKit

class SignInCoordinator: Coordinator, NavigationCoordinator {
  var childCoordinators: [Coordinator] = []
  
  weak var parentCoordinator: Coordinator?
  var navigationController: UINavigationController
  private let container: Container
  
  init(navigationController: UINavigationController, container: Container) {
    self.navigationController = navigationController
    self.container = container
  }
  
  func start() {
    let viewModel = container.resolve(SignInViewModel.self)!
    let vc = SignInViewController(coordinator: self, viewModel: viewModel)
    navigationController.setViewControllers([vc], animated: true)
  }
  
  func didFinishSign() {
    parentCoordinator?.removeChildCoordinator(self)
    (parentCoordinator as? AppCoordinator)?.showMainTabbar()
  }
}

