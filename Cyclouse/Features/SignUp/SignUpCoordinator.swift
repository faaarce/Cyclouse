//
//  SignUpCoordinator.swift
//  Cyclouse
//
//  Created by yoga arie on 20/09/24.
//
import Swinject
import UIKit

protocol SignUpCoordinatorDelegate: AnyObject {
    func signUpCoordinatorDidFinish(_ coordinator: SignUpCoordinator)
}

class SignUpCoordinator: Coordinator,
                         NavigationCoordinator {
  var childCoordinators: [Coordinator] = []
  weak var parentCoordinator: Coordinator?
  var navigationController: UINavigationController
  weak var delegate: SignUpCoordinatorDelegate?
  
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
    delegate?.signUpCoordinatorDidFinish(self)
    parentCoordinator?.removeChildCoordinator(self)
    navigationController.popViewController(animated: true)
    
  }
}

