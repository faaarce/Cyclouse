//
//  ForgotCoordinator.swift
//  Cyclouse
//
//  Created by yoga arie on 25/06/25.
//
import Swinject
import Foundation
import UIKit

// The delegate protocol for this specific coordinator.
protocol ForgotCoordinatorDelegate: AnyObject {
  func forgotCoordinatorDidFinish(_ coordinator: ForgotCoordinator)
}

class ForgotCoordinator: Coordinator, NavigationCoordinator {
  var childCoordinators: [Coordinator] = []
  
  weak var parentCoordinator: Coordinator?
  var navigationController: UINavigationController
  
  // This delegate should be of its own type, not SignUpCoordinatorDelegate.
  weak var delegate: ForgotCoordinatorDelegate?
  
  private let container: Container
  
  init(navigationController: UINavigationController, container: Container) {
    self.navigationController = navigationController
    self.container = container
  }
  
  /// Creates the ViewModel and ViewController and pushes it onto the navigation stack.
  func start() {
    // 1. Resolve the ViewModel from the dependency container.
    let viewModel = container.resolve(ForgotViewModel.self)!
    
    // 2. Initialize the ViewController, injecting the coordinator itself and the viewModel.
    let vc = ForgotViewController(coordinator: self, viewModel: viewModel)
    
    // 3. Push the fully configured ViewController.
    navigationController.pushViewController(vc, animated: true)
  }
  
  /// Called from the ForgotViewController when the user successfully submits their email.
  /// This function is responsible for navigating to the next step in the flow.
  func navigateToVerificationScreen(_ email: String) {
   
    let verificationCoordinator = container.resolve(OTPCoordinator.self, arguments: navigationController, email)! //ERROR
    addChildCoordinator(verificationCoordinator)
    verificationCoordinator.parentCoordinator = self
    verificationCoordinator.start()
  }
  
  /// Called by a parent coordinator to dismiss this flow.
  func didFinish() {
    delegate?.forgotCoordinatorDidFinish(self)
    parentCoordinator?.removeChildCoordinator(self)
    // You might or might not pop the view controller here,
    // depending on whether the parent coordinator handles the dismissal.
    // For a simple pop, you can add:
    // navigationController.popViewController(animated: true)
  }
}
