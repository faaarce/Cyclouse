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
  
  func signOut() -> AnyPublisher<APIResponse<SignoutResponse>, Error> {
    apiService.request(AuthenticationAPI.signout, includeHeaders: true)
  }
  
  func signUp(name: String, email: String, phone: String, password: String) -> AnyPublisher<APIResponse<SignupResponse>,  Error> {
    apiService.request(AuthenticationAPI.signup(name: name, email: email, phone: phone, password: password), includeHeaders: true)
  }
  
  func forgot(email: String) -> AnyPublisher<APIResponse<ForgotResponse>, Error> {
    apiService.request(AuthenticationAPI.forgot(email: email), includeHeaders: false)
  }
  
  func verify(email: String, code:String) -> AnyPublisher<APIResponse<VerifyResponse>, Error>{
    apiService.request(AuthenticationAPI.verify(email: email, code: code), includeHeaders: false)
  }
  
  func reset(email: String, code:String, newPassword: String) -> AnyPublisher<APIResponse<ResetResponse>, Error> {
    apiService.request(AuthenticationAPI.reset(email: email, code: code, resetPassword: newPassword), includeHeaders: false)
  }
  
  
}
