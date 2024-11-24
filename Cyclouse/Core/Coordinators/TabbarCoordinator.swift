//
//  TabbarCoordinator.swift
//  Cyclouse
//
//  Created by yoga arie on 05/09/24.
//

import UIKit
import Combine
import Swinject

final class TabbarCoordinator: Coordinator {
    
    // MARK: - Coordinator Properties
    
    var childCoordinators: [Coordinator] = []
    weak var parentCoordinator: Coordinator?
    
    // MARK: - Private Properties
    
    private let container: Container
    private var tabBarController: TabBarController
    private let service = DatabaseService.shared
    
    private enum Tab: Int, CaseIterable {
        case home
        case profile
        
        var title: String {
            switch self {
            case .home: return "Home"
            case .profile: return "Profile"
            }
        }
        
        var inactiveIcon: String {
            switch self {
            case .home: return "home_icon_inactive"
            case .profile: return "profile_icon_inactive"
            }
        }
        
        var activeIcon: String {
            switch self {
            case .home: return "home_icon_active"
            case .profile: return "profile_icon_active"
            }
        }
    }
    
    // MARK: - Initialization
    
    init(tabBarController: UITabBarController, container: Container) {
        self.tabBarController = TabBarController()
        self.container = container
    }
    
    // MARK: - Coordinator Methods
    
    func start() {
        setupViewControllers()
        startWithRoot(tabBarController)
    }
    
    // MARK: - Setup Methods
    
    private func setupViewControllers() {
        let viewControllers = createViewControllers()
        configureTabBar(with: viewControllers)
        setupTabBarItems()
    }
    
    private func createViewControllers() -> [UINavigationController] {
        return [
            createHomeNavigationController(),
            createProfileNavigationController()
        ]
    }
    
    private func createHomeNavigationController() -> UINavigationController {
        let navigationController = UINavigationController()
        setupCoordinator(HomeCoordinator.self, with: navigationController)
        return navigationController
    }
    
    private func createProfileNavigationController() -> UINavigationController {
        let navigationController = UINavigationController()
        setupCoordinator(ProfileCoordinator.self, with: navigationController)
        return navigationController
    }
    
    private func setupCoordinator<T: Coordinator>(_ type: T.Type, with navigationController: UINavigationController) {
        guard let coordinator = container.resolve(type, argument: navigationController) else { return }
        addChildCoordinator(coordinator)
        coordinator.start()
    }
    
    private func configureTabBar(with viewControllers: [UIViewController]) {
        tabBarController.setViewControllers(viewControllers, animated: false)
    }
    
    private func setupTabBarItems() {
        guard let viewControllers = tabBarController.viewControllers else { return }
        
        Tab.allCases.forEach { tab in
            viewControllers[tab.rawValue].tabBarItem = createTabBarItem(for: tab)
        }
    }
    
    private func createTabBarItem(for tab: Tab) -> UITabBarItem {
        UITabBarItem(
            title: tab.title,
            image: UIImage(named: tab.inactiveIcon)?
                .withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: tab.activeIcon)?
                .withRenderingMode(.alwaysTemplate)
        )
    }
    
    // MARK: - Logout Handling
    
    func handleLogout() {
        cleanupCoordinators()
        notifyParentOfLogout()
    }
    
    private func cleanupCoordinators() {
        childCoordinators.forEach { $0.didFinish() }
        childCoordinators.removeAll()
        didFinish()
    }
    
    private func notifyParentOfLogout() {
        (parentCoordinator as? AppCoordinator)?.handleLogout()
    }
}
