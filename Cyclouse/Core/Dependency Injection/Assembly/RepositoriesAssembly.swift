//
//  RepositoriesAssembly.swift
//  Cyclouse
//
//  Created by yoga arie on 31/10/24.
//

import Foundation
import Swinject
import UIKit

class RepositoriesAssembly: Assembly {
    func assemble(container: Container) {
        // MARK: - Auth Repository
        container.register(AuthenticationRepository.self) { r in
            let apiService = r.resolve(APIService.self)!
            return AuthenticationNetworkRepository(apiService: apiService)
        }.inObjectScope(.container)
        
        // MARK: - Cart Repository
        container.register(CartRepository.self) { r in
            let apiService = r.resolve(APIService.self)!
            return CartNetworkRepository(apiService: apiService)
        }.inObjectScope(.container)
        
        // MARK: - Bike Repository
        container.register(BikeRepository.self) { r in
            let apiService = r.resolve(APIService.self)!
            return BikeNetworkRepository(apiService: apiService)
        }.inObjectScope(.container)
        
        // Add other repositories as needed...
    }
}
