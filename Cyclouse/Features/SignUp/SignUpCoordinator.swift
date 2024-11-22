//
//  SignUpCoordinator.swift
//  Cyclouse
//
//  Created by yoga arie on 20/09/24.
//
import Swinject
import UIKit

class SignUpCoordinator: Coordinator,
                         NavigationCoordinator {
  var childCoordinators: [Coordinator] = []
  weak var parentCoordinator: Coordinator?
  var navigationController: UINavigationController
  
  private let container: Container
  
  init(navigationController: UINavigationController, container: Container) {
    self.navigationController = navigationController
    
    self.container = container
  }
  
  func start() {
    let viewModel = container.resolve(SignUpViewModel.self)!
    let vc = SignUpViewController(coordinator: self, viewModel: viewModel)
    navigationController.pushViewController(vc, animated: true)
  }
  
  func didFinishSignUp() {
    parentCoordinator?.removeChildCoordinator(self)
    navigationController.popViewController(animated: true)
  }
}

