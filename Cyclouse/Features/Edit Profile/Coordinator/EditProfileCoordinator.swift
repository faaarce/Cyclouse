//
//  EditProfileCoordinator.swift
//  Cyclouse
//
//  Created by yoga arie on 25/11/24.
//

import Foundation
import UIKit
import Swinject

class EditProfileCoordinator: Coordinator, NavigationCoordinator {
    var childCoordinators: [Coordinator] = []
    weak var parentCoordinator: Coordinator?
    var navigationController: UINavigationController
    private let userData: UserProfile
    private let container: Container
    
    init(navigationController: UINavigationController, userData: UserProfile, container: Container) {
        self.navigationController = navigationController
        self.userData = userData
        self.container = container
    }
    
    func start() {
      let editProfileVC = EditProfileViewController(coordinator: self, userData: userData)
        editProfileVC.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(editProfileVC, animated: true)
    }
    
    func didFinish() {
        parentCoordinator?.removeChildCoordinator(self)
    }
    
    // Add any additional navigation methods if needed
    func popToRoot() {
        navigationController.popToRootViewController(animated: true)
    }
}
