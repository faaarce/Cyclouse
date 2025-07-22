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
    
    
    container.register(EditProfileCoordinator.self) { (resolver, navigationController: UINavigationController, profile: UserProfiles) in
      EditProfileCoordinator(navigationController: navigationController, userData: profile, container: container)
    }
    
    container.register(DetailOrderCoordinator.self) { (resolver, navigationController: UINavigationController, orderData: OrderHistory) in
      DetailOrderCoordinator(navigationController: navigationController, container: container, orderData: orderData)
    }
    
    container.register(ForgotCoordinator.self) { (resolver, navigationController: UINavigationController) in
      ForgotCoordinator(navigationController: navigationController, container: container)
    }
    
    container.register(OTPCoordinator.self) { (resolver, navigationController: UINavigationController, email: String) in
        // Notice: 'email' here is a parameter name, not a value
        // It's like defining a function parameter - you name it, but don't give it a value yet
        return OTPCoordinator(
            navigationController: navigationController,
            container: container,
            email: email  // This uses the email parameter from above
        )
    }
    
    
    container.register(ResetCoordinator.self) { (resolver, navigationController: UINavigationController, email: String, code: String) in
        // Notice: 'email' here is a parameter name, not a value
        // It's like defining a function parameter - you name it, but don't give it a value yet
      return ResetCoordinator(
            navigationController: navigationController,
            container: container,
            email: email,
            code: code
            // This uses the email parameter from above
        )
    }
    
    
  
  }
}
