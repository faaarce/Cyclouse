//
//  ResetCoordinator.swift
//  Cyclouse
//
//  Created by yoga arie on 30/06/25.
//

import Foundation
import UIKit
import Swinject

protocol ResetCoordinatorDelegate: AnyObject {
  func resetCoordinatorDidFinish(_ coordinator: ResetCoordinator)
}

class ResetCoordinator: Coordinator, NavigationCoordinator {
  var childCoordinators: [Coordinator] = []
  var parentCoordinator: Coordinator?
  var navigationController: UINavigationController
  weak var delegate: ResetCoordinatorDelegate?
  private let email: String
  private let code: String
  
  private let container: Container
  
  init(navigationController: UINavigationController, container: Container, email: String, code: String) {
    self.navigationController = navigationController
    self.container = container
    self.email = email
    self.code = code
  }
  
  func start() {
    let viewModel = container.resolve(ResetViewModel.self, arguments: email, code)!
    let vc = ResetViewController(coordinator: self, viewModel: viewModel)
    navigationController.pushViewController(vc, animated: true)
    
  }
  
  func didFinish() {
    delegate?.resetCoordinatorDidFinish(self)
    parentCoordinator?.removeChildCoordinator(self)
  }
  

}

/*
 their data
 NotificationCenter.default.post(name: Notification.Name.paymentCompleted, object: nil)
 
 // Clean up current coordinator
 coordinator.didFinish()
 
 // Dismiss this view controller and pop to root
 dismiss(animated: true) { [weak self] in
   self?.navigationController?.popToRootViewController(animated: true)
   
   // Find the tab bar controller and switch to home tab
   if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
      let window = windowScene.windows.first,
      let tabBarController = window.rootViewController as? UITabBarController {
     tabBarController.selectedIndex = 0 // Switch to home tab
   }
 }
 */
