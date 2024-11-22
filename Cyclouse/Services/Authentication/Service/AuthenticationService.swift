//
//  AuthenticationService.swift
//  FoodApp
//
//  Created by Phincon on 16/07/24.
//
import Combine


class AuthenticationService {
    let repository: AuthenticationRepository
    
    init(repository: AuthenticationRepository = AuthenticationNetworkRepository()) {
        self.repository = repository
    }
    
  func signIn(email: String, password: String) -> AnyPublisher<APIResponse<SignInResponse>, Error> {
        if let error = Email.validate(email) {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        if let error = Password.validate(password) {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return repository
            .signIn(email: email, password: password)
            .eraseToAnyPublisher()
    }
  
  func signOut() -> AnyPublisher<APIResponse<SignoutResponse>, Error> {
    return repository
      .signOut()
      .eraseToAnyPublisher()
  }
  
  func signUp(name: String, email: String, phone: String, password: String) -> AnyPublisher<APIResponse<SignupResponse>, Error> {
    if let error = Email.validate(email) {
        return Fail(error: error).eraseToAnyPublisher()
    }
    
    if let error = Password.validate(password) {
        return Fail(error: error).eraseToAnyPublisher()
    }
    
    return repository.signUp(name: name, email: email, phone: phone, password: password)

  }
}
