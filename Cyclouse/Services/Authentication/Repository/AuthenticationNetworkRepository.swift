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
  
  func signIn(username: String, password: String) -> AnyPublisher<SignInResponse, Error>  {
    apiService.request(AuthenticationAPI.signin(username: username, password: password))
  }
  
  
}