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
    
    container.register(CartViewModel.self) { r in
      let databaseService = r.resolve(DatabaseService.self)!
      return CartViewModel()
    }
    
    container.register(SignUpViewModel.self) { r in
      let authService = r.resolve(AuthenticationService.self)!
      return SignUpViewModel(authenticationService: authService)
    }
    
    container.register(ForgotViewModel.self) { r in
      let authService = r.resolve(AuthenticationService.self)!
      return ForgotViewModel(authenticationService: authService)
  
    }
    
    container.register(OTPVerificationViewModel.self) { (r, email: String) in
      let authService = r.resolve(AuthenticationService.self)!
      return OTPVerificationViewModel(email: email, authenticationService: authService)
    }
    
    container.register(ResetViewModel.self) { (r, email: String, code: String) in
      let authService = r.resolve(AuthenticationService.self)!
      return ResetViewModel(authenticationService: authService, email: email, code: code)    }
    
    
  }
  
  
}
