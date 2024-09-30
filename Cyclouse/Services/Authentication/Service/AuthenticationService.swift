//
//  AuthenticationService.swift
//  FoodApp
//
//  Created by Phincon on 16/07/24.
//
import Combine
import Valet

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
}
