//
//  ViewModelsAssembly.swift
//  Cyclouse
//
//  Created by yoga arie on 31/10/24.
//
import Swinject
import Foundation

class ViewModelsAssembly: Assembly {
  func assemble(container: Container) {
    container.register(SignInViewModel.self) { r in
      let authService = r.resolve(AuthServiceProtocol.self)!
      return SignInViewModel(authService: authService)
    }
    
    
    // MARK: - Detail ViewModel
      container.register(DetailViewModel.self) { (r, product: Product) in
          let cartService = r.resolve(CartService.self)!
          let databaseService = r.resolve(DatabaseService.self)!
          return DetailViewModel(
              product: product,
              cartService: cartService,
              databaseService: databaseService
          )
      }
  }
  
  
}
