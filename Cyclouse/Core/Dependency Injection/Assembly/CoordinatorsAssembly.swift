//
//  CoordinatorsAssembly.swift
//  Cyclouse
//
//  Created by yoga arie on 31/10/24.
//

import Foundation
import Swinject
import UIKit

class CoordinatorsAssembly: Assembly {
  func assemble(container: Container) {
    // MARK: - SignIn Coordinator
    container.register(SignInCoordinator.self) { (r, navigationController: UINavigationController) in
      SignInCoordinator(
        navigationController: navigationController,
        container: container
      )
    }
    
    // MARK: - Detail Coordinator
    container.register(DetailCoordinator.self) { (r, navigationController: UINavigationController, product: Product) in
      DetailCoordinator(
        navigationController: navigationController,
        product: product,
        container: container
      )
    }
    
    container.register(SignUpCoordinator.self) { (r, navigationController: UINavigationController) in
      SignUpCoordinator(navigationController: navigationController, container: container)
    }
    
    container.register(HomeCoordinator.self) { (r, navigationController: UINavigationController) in
      HomeCoordinator(
        navigationController: navigationController,
        container: container
      )
    }
    
    // MARK: - Tabbar Coordinator
    container.register(TabbarCoordinator.self) { (r, tabBarController: UITabBarController) in
      TabbarCoordinator(
        tabBarController: tabBarController,
        container: container
      )
    }
    container.register(AppCoordinator.self) { (resolver, navigationController: UINavigationController) in
      AppCoordinator(
        navigationController: navigationController,
        container: container
      )
    }
    
    container.register(CartCoordinator.self) { (resolver, navigationController: UINavigationController) in
      CartCoordinator(navigationController: navigationController, container: container)
    }
    
    container.register(CheckoutCoordinator.self) { (resolver, navigationController: UINavigationController, bike: [BikeDatabase]) in
      CheckoutCoordinator(navigationController: navigationController, container: container, bike: bike)
    }
    
    container.register(ProfileCoordinator.self) { (resolver, navigationController: UINavigationController) in
      ProfileCoordinator(navigationController: navigationController, container: container)
    }
    
    container.register(HistoryCoordinator.self) { (resolver, navigationController: UINavigationController) in
      HistoryCoordinator(navigationController: navigationController, container: container)
    }
    
    container.register(PaymentCoordinator.self) { (resolver, navigationController: UINavigationController, checkoutData: CheckoutData) in
      PaymentCoordinator(navigationController: navigationController, paymentDetail: checkoutData, container: container)
    }
  }
}
