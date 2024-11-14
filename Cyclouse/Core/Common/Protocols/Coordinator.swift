//
//  Coordinator.swift
//  Cyclouse
//
//  Created by yoga arie on 05/09/24.
//

import UIKit

protocol Coordinator: AnyObject {
  var childCoordinators: [Coordinator] { get set }
  var parentCoordinator: Coordinator? { get set }
  
  func start()
  func removeChildCoordinator(_ coordinator: Coordinator)
  func addChildCoordinator(_ coordinator: Coordinator)
  func didFinish()
}

extension Coordinator {
  
  func didFinish() {
    parentCoordinator?.removeChildCoordinator(self)
  }
  
  func removeChildCoordinator(_ coordinator: Coordinator) {
    childCoordinators.removeAll { $0 === coordinator }
  }
  
  func addChildCoordinator(_ coordinator: Coordinator) {
    coordinator.parentCoordinator = self
    childCoordinators.append(coordinator)
  }
  
  func startWithRoot(_ vc: UIViewController) {
    let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
    let window = windowScene?.windows.first(where: { $0.isKeyWindow })
    window?.rootViewController = vc
  }
  
}
