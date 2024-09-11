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
}

extension Coordinator {
  func removeChildCoordinator(_ coordinator: Coordinator) {
    childCoordinators.removeAll { $0 === coordinator }
  }
  
  func addChildCoordinator(_ coordinator: Coordinator) {
    self.childCoordinators.append(coordinator)
    // Question: childCoordinators it just a blueprint or there a real property
    coordinator.parentCoordinator = self
    // Question: Who is self
  }
  
  func startWithRoot(_ vc: UIViewController) {
    let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
    let window = windowScene?.windows.first(where: { $0.isKeyWindow })
    window?.rootViewController = vc
  }
  
  func getParentCoordinator<T: Coordinator>(from coordinator: Coordinator) -> T? {
    let parent = coordinator.parentCoordinator
    if let parent = parent as? T {
      return parent
    } else if let parent {
      return getParentCoordinator(from: parent)
    }
    return nil
  }
}
