//
//  ServicesAssembly.swift
//  Cyclouse
//
//  Created by yoga arie on 31/10/24.
//

import Foundation
import Swinject

import Swinject

class ServicesAssembly: Assembly {
    func assemble(container: Container) {
        // MARK: - API Service
        container.register(APIService.self) { _ in
            APIManager()
        }.inObjectScope(.container)
        
        // MARK: - Authentication Repository
        container.register(AuthenticationRepository.self) { r in
            let apiService = r.resolve(APIService.self)!
            return AuthenticationNetworkRepository(apiService: apiService)
        }.inObjectScope(.container)
        
        // MARK: - Authentication Service
        container.register(AuthenticationService.self) { r in
            let repository = r.resolve(AuthenticationRepository.self)!
            return AuthenticationService(repository: repository)
        }.inObjectScope(.container)
        
        // MARK: - Database Service
        container.register(DatabaseService.self) { _ in
            DatabaseService.shared
        }.inObjectScope(.container)
      
      // MARK: - Auth Services
             container.register(AuthServiceProtocol.self) { _ in
                 AuthService()
             }.inObjectScope(.container)
             
             container.register(AuthenticationService.self) { r in
                 let repository = r.resolve(AuthenticationNetworkRepository.self)!
                 return AuthenticationService(repository: repository)
             }.inObjectScope(.container)
             
             // MARK: - Database Service
             container.register(DatabaseService.self) { _ in
                 DatabaseService.shared
             }.inObjectScope(.container)
             
             // MARK: - Cart Service
             container.register(CartService.self) { _ in
                 CartService()
             }.inObjectScope(.container)
             
             // MARK: - Repositories
             container.register(AuthenticationNetworkRepository.self) { r in
                 let apiService = r.resolve(APIService.self)!
                 return AuthenticationNetworkRepository(apiService: apiService)
             }.inObjectScope(.container)
             
             // MARK: - API Service
             container.register(APIService.self) { _ in
                 APIManager()
             }.inObjectScope(.container)
    }
}
