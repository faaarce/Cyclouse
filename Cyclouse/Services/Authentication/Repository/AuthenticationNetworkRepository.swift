//
//  AuthenticationNetworkRepository.swift
//  exercise4
//
//  Created by Phincon on 15/07/24.
//
import Combine

class AuthenticationNetworkRepository: AuthenticationRepository {
    let apiService: APIService
    
    init(apiService: APIService = APIManager()) {
        self.apiService = apiService
    }
    
    func signIn(email: String, password: String) -> AnyPublisher<APIResponse<SignInResponse>, Error> {
        apiService.request(AuthenticationAPI.signin(email: email, password: password), includeHeaders: true)
    }
}
