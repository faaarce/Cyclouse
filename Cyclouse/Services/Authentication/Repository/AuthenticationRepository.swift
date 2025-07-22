//
//  AuthenticationRepository.swift
//  exercise4
//
//  Created by Phincon on 15/07/24.
//

import Foundation
import Combine

protocol AuthenticationRepository {
    func signIn(email: String, password: String) -> AnyPublisher<APIResponse<SignInResponse>, Error>
  
  func signOut() -> AnyPublisher<APIResponse<SignoutResponse>, Error>
  
  func signUp(name: String, email: String, phone: String, password: String) -> AnyPublisher<APIResponse<SignupResponse>, Error>
  
  func forgot(email: String) -> AnyPublisher<APIResponse<ForgotResponse>, Error>
  
  func verify(email: String, code:String) -> AnyPublisher<APIResponse<VerifyResponse>, Error>
  
  func reset(email: String, code:String, newPassword: String) -> AnyPublisher<APIResponse<ResetResponse>, Error>
  
  
}


