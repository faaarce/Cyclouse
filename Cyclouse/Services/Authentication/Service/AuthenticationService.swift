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
    
    func signIn(username: String, password: String) -> AnyPublisher<SignInResponse, Error> {
        if let error = Username.validate(username) {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        if let error = Password.validate(password) {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return repository
            .signIn(username: username, password: password)
            .eraseToAnyPublisher()
    }
}
