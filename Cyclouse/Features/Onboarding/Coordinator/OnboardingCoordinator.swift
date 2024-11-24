//
//  OnboardingCoordinator.swift
//  Cyclouse
//
//  Created by yoga arie on 06/09/24.
//

import UIKit

protocol OnboardingCoordinatorDelegate: AnyObject {
  func onboardingComplete()
}

class OnboardingCoordinator: Coordinator, NavigationCoordinator {
  var childCoordinators: [any Coordinator] = []
  
  weak var parentCoordinator: (any Coordinator)?
  
  unowned var navigationController: UINavigationController
  weak var delegate: OnboardingCoordinatorDelegate?
  
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  func start() {
    let vc = OnboardingViewController(coordinator: self)
    navigationController.pushViewController(vc, animated: true)
  }
  
  func finishOnboarding() {
        TokenManager.shared.setOnboardingComplete()
        delegate?.onboardingComplete()
        didFinish()
    }
  
  
}
