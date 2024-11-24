//
//  SignUpViewModel.swift
//  Cyclouse
//
//  Created by yoga arie on 21/11/24.
//

import Foundation
import Combine
import UIKit

class SignUpViewModel: ObservableObject {
  @Published var email: String? = ""
  @Published var name: String? = ""
  @Published var password: String? = ""
  @Published var phoneNumber: String? = ""
  @Published var isLoading = false
  @Published var confirmPassword: String? = ""
  
  let signUpTapped = PassthroughSubject<Void, Never>()
  let errorMessage = PassthroughSubject<String, Never>()
  let signUpSuccess = PassthroughSubject<Void, Never>()
  let updatePlaceholderColors = PassthroughSubject<(isNameValid: Bool, isEmailValid: Bool, isPasswordValid: Bool, isConfirmPasswordValid: Bool, isNumberValid: Bool), Never>()
  
  private var cancellables = Set<AnyCancellable>()
  private let authenticationService: AuthenticationService
  
  init(authenticationService: AuthenticationService = AuthenticationService()) {
    self.authenticationService = authenticationService
    setupBindings()
  }
  
  private func setupBindings() {
        signUpTapped
            .map { [weak self] _ in
                guard let self = self else { return (name: "", email: "", password: "", confirmPassword: "", phoneNumber: "") }
                return (
                    name: self.name ?? "",
                    email: self.email ?? "",
                    password: self.password ?? "",
                    confirmPassword: self.confirmPassword ?? "",
                    phoneNumber: self.phoneNumber ?? ""
                )
            }
            .sink { [weak self] credentials in
                self?.validateAndSignUp(
                    name: credentials.name,
                    email: credentials.email,
                    password: credentials.password,
                    confirmPassword: credentials.confirmPassword,
                    phoneNumber: credentials.phoneNumber
                )
            }
            .store(in: &cancellables)
    }
    
    private func validateAndSignUp(name: String, email: String, password: String, confirmPassword: String, phoneNumber: String) {
        let isNameValid = name.count >= 3
        let isEmailValid = email.isValidEmail
      let isPasswordValid = password.count >= 3
        let isConfirmPasswordValid = password == confirmPassword && !password.isEmpty
      let isNumberValid = phoneNumber.count >= 3
        
        updatePlaceholderColors.send((
            isNameValid: isNameValid,
            isEmailValid: isEmailValid,
            isPasswordValid: isPasswordValid,
            isConfirmPasswordValid: isConfirmPasswordValid,
            isNumberValid: isNumberValid
        ))
        
        if !isNameValid || !isEmailValid || !isPasswordValid || !isConfirmPasswordValid {
            var errorMessage = ""
            if !isNameValid { errorMessage += "Name must be at least 3 characters\n" }
            if !isEmailValid { errorMessage += "Invalid email format\n" }
            if !isPasswordValid { errorMessage += "Password must be at least 8 characters with numbers\n" }
            if !isConfirmPasswordValid { errorMessage += "Passwords do not match\n" }
          
            self.errorMessage.send(errorMessage)
            return
        }
        
        signUp(name: name, email: email, password: password, phoneNumber: phoneNumber)
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
  
  
  
  func signUp(name: String, email: String, password: String, phoneNumber: String) {
    isLoading = true
    authenticationService.signUp(name: name, email: email, phone: phoneNumber, password: password)
      .sink { [weak self] completionResult in
        DispatchQueue.main.async {
          guard let self = self else { return }
          self.isLoading = false
          
          switch completionResult {
          case .finished:
            break
            
          case .failure(let error):
            if let urlError = error as? URLError {
              self.errorMessage.send("Network error: \(urlError.localizedDescription)")
            } else {
              self.errorMessage.send("An error occurred: \(error.localizedDescription)")
            }
          }
        }
      } receiveValue: { [weak self] response in
        DispatchQueue.main.async {
          if response.value.success {
            self?.signUpSuccess.send()
          } else {
            self?.errorMessage.send("Signup failed, Please try again.")
          }
        }
      }
      .store(in: &cancellables)
      }
  }

