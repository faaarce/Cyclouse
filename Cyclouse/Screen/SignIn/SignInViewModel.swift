//
//  SignInViewModel.swift
//  Cyclouse
//
//  Created by yoga arie on 21/09/24.
//

import Foundation
import Combine
import UIKit

class SignInViewModel: ObservableObject {
  @Published var email: String? = ""
  @Published var password: String? = ""
  @Published var isLoading = false
  
  let signInTapped = PassthroughSubject<Void, Never>()
  let errorMessage = PassthroughSubject<String, Never>()
  let loginSuccess = PassthroughSubject<Void, Never>()
  let updatePlaceholderColors = PassthroughSubject<(isEmailValid: Bool, isPasswordValid: Bool), Never>()
  
  private let authService: AuthServiceProtocol
  private var cancellables = Set<AnyCancellable>()
  
  init(authService: AuthServiceProtocol = AuthService()) {
    self.authService = authService
    setupBindings()
  }
  
  private func setupBindings(){
    signInTapped
      .map { [weak self] _ in
        guard let self = self else { return (email: "", password: "") }
        return (email: self.email ?? "", password: self.password ?? "")
      }
      .sink { [weak self] credentials in
        self?.validateAndSignIn(email: credentials.email, password: credentials.password)
      }
      .store(in: &cancellables)
  }
  
  private func validateAndSignIn(email: String, password: String) {
    let isEmailValid = email.isValidEmail
    let isPasswordValid = password.count >= 3
    
    updatePlaceholderColors.send((isEmailValid: isEmailValid, isPasswordValid: isPasswordValid))
    if !isEmailValid || !isPasswordValid {
      var errorMessage = ""
      if !isEmailValid { errorMessage += "Invalid email format\n" }
      if !isPasswordValid { errorMessage += "Invalid password format" }
      self.errorMessage.send(errorMessage)
      return
    }
    
    signIn(email: email, password: password)
    
  }
  
  private func signIn(email: String, password: String) {
    isLoading = true
    
    authService.signIn(email: email, password: password) { [weak self] result in
      DispatchQueue.main.async {
        guard let self = self else { return }
        self.isLoading = false
        
        switch result {
        case .success:
          self.loginSuccess.send()
          
        case .failure(let error):
          switch error {
          case .invalidCredentials:
            self.errorMessage.send("Invalid email or password. Please try again.")
            
          case .networkError(let error):
            self.errorMessage.send("Network error: \(error.localizedDescription)")
            
          case .unknown:
            self.errorMessage.send("An unknown error occurred. Please try again.")
          }
        }
      }
    }
  }
  
}

protocol AuthServiceProtocol {
  func signIn(email: String, password: String, completion: @escaping (Result<Void, AuthError>) -> Void)
}

class AuthService: AuthServiceProtocol {
  
  private var authenticationManager = AuthenticationService()
  private var cancellables = Set<AnyCancellable>()
  
  func signIn(email: String, password: String, completion: @escaping (Result<Void, AuthError>) -> Void) {
          authenticationManager.signIn(username: email, password: password)
              .sink(receiveCompletion: { [weak self] completionResult in
                  switch completionResult {
                  case .finished:
                      break // We'll handle success in receiveValue
                  case .failure(let error):
                      if let authError = self?.mapError(error) {
                          completion(.failure(authError))
                      } else {
                          completion(.failure(.unknown))
                      }
                  }
              }, receiveValue: { signInResponse in
                  if signInResponse.success {
                      completion(.success(()))
                  } else {
                      completion(.failure(.invalidCredentials))
                  }
              })
              .store(in: &cancellables)
      }
      
      private func mapError(_ error: Error) -> AuthError {
  
          switch error {
          case is URLError:
              return .networkError(error)
          case is DecodingError:
              return .unknown // or a more specific error if you have one for decoding issues
          default:
              return .unknown
          }
      }
}

enum AuthError: Error {
  case invalidCredentials
  case networkError(Error)
  case unknown
}
