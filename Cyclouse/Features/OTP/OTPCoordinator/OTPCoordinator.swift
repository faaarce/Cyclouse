//
//  OTPCoordinator.swift
//  Cyclouse
//
//  Created by yoga arie on 29/06/25.
//
import Swinject
import Foundation
import UIKit

protocol OTPCoordinatorDelegate: AnyObject {
  func otpCoordinatorDidFinish(_ coordinator: OTPCoordinator)
}

class OTPCoordinator: Coordinator, NavigationCoordinator {
  var childCoordinators: [Coordinator] = []
  weak var parentCoordinator: Coordinator?
  var navigationController: UINavigationController
  weak var delegate: OTPCoordinatorDelegate?
  private let container: Container
  private let email: String
  
  init(navigationController: UINavigationController, container: Container, email: String) {
         self.navigationController = navigationController
         self.container = container
         self.email = email
     }
  
  func start() {
    let viewModel = container.resolve(OTPVerificationViewModel.self, argument: email)! // now its error
    let vc = OTPVerificationViewController(coordinator: self, viewModel: viewModel)
    navigationController.pushViewController(vc, animated: true)
  }
  
  func navigateToResetScreen() {
    let resetCoordinator = container.resolve(ResetCoordinator.self, arguments: navigationController, self.email, "1234")! // ERROR fix this
    addChildCoordinator(resetCoordinator)
    resetCoordinator.parentCoordinator = self
    resetCoordinator.start()
  }
  
  func didFinish() {
    delegate?.otpCoordinatorDidFinish(self)
    parentCoordinator?.removeChildCoordinator(self)
  }
  
  
}

