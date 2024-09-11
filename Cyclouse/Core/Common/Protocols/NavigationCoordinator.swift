//
//  NavigationCoordinator.swift
//  Cyclouse
//
//  Created by yoga arie on 05/09/24.
//

import UIKit

protocol NavigationCoordinator: AnyObject {
  var navigationController: UINavigationController { get set }
}

extension NavigationCoordinator {
  func startWithRootNavigation(_ vc: UIViewController) {
    let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
    let window = windowScene?.windows.first(where: { $0.isKeyWindow })
    let nav = window?.rootViewController as? UINavigationController
    
    if nav === navigationController {
      navigationController.setViewControllers([vc], animated: true)
    } else if nav != nil {
      nav?.setViewControllers([vc], animated: true)
      self.navigationController = nav!
    } else {
      self.navigationController = UINavigationController(rootViewController: vc)
      window?.rootViewController = self.navigationController
    }
  }
}
