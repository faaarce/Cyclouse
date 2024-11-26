//
//  SignInViewModel.swift
//  Cyclouse
//
//  Created by yoga arie on 21/09/24.
//
import Foundation
import Combine
import UIKit
import Valet

class SignInViewModel: ObservableObject {
    @Published var email: String? = ""
    @Published var password: String? = ""
    @Published var isLoading = false
    
    // MARK: - Publishers
    let signInTapped = PassthroughSubject<Void, Never>()
    let errorMessage = PassthroughSubject<String, Never>()
    let loginSuccess = PassthroughSubject<Void, Never>()
    let updatePlaceholderColors = PassthroughSubject<(isEmailValid: Bool, isPasswordValid: Bool), Never>()
    
    // MARK: - Dependencies
    private let authService: AuthServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
        setupBindings()
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
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
                    self.handleError(error)
                }
            }
        }
    }
    
    private func handleError(_ error: AuthError) {
        let message = switch error {
        case .invalidCredentials:
            "Invalid email or password. Please try again."
        case .networkError(let error):
            "Network error: \(error.localizedDescription)"
        case .unknown:
            "An unknown error occurred. Please try again."
        }
        errorMessage.send(message)
    }
}

// MARK: - Auth Service Protocol
protocol AuthServiceProtocol {
    func signIn(email: String, password: String, completion: @escaping (Result<Void, AuthError>) -> Void)
}

// MARK: - Auth Service Implementation
class AuthService: AuthServiceProtocol {
    private var authenticationManager = AuthenticationService()
    private var cancellables = Set<AnyCancellable>()
    private let valetService: ValetServiceProtocol
    
    init(valetService: ValetServiceProtocol = ValetService.shared) {
        self.valetService = valetService
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<Void, AuthError>) -> Void) {
        authenticationManager.signIn(email: email, password: password)
            .sink(receiveCompletion: { [weak self] completionResult in
                switch completionResult {
                case .finished:
                    break
                case .failure(let error):
                    if let authError = self?.mapError(error) {
                        completion(.failure(authError))
                    } else {
                        completion(.failure(.unknown))
                    }
                }
            }, receiveValue: { [weak self] response in
              self?.handleSignInResponse(response, completion: completion)
            })
            .store(in: &cancellables)
    }
    
    // MARK: - Private Methods
  private func handleSignInResponse( _ response: APIResponse<SignInResponse>, completion: @escaping (Result<Void, AuthError>) -> Void) {
    guard response.value.success,
              let authHeader =
                response.httpResponse?.allHeaderFields["Authorization"] as? String else { //ERROR: -Type of expression is ambiguous without a type annotation
            completion(.failure(.invalidCredentials))
            return
        }
        
        do {
            // Save auth data
          TokenManager.shared.saveLoginData(token: authHeader, userId: response.value.userId)
            
            // Create and save user profile
            let userProfile = UserProfiles(
              userId: response.value.userId,
              email: response.value.email,
              name: response.value.name, phone: response.value.phone
            )
            try valetService.save(userProfile, for: .userProfile)
            
            print("✅ Login successful - All data saved")
            completion(.success(()))
            
        } catch {
            print("❌ Failed to save user profile:", error)
            completion(.failure(.unknown))
        }
    }
    
    private func mapError(_ error: Error) -> AuthError {
        switch error {
        case is URLError:
            return .networkError(error)
        case is DecodingError:
            return .unknown
        default:
            return .unknown
        }
    }
}

// MARK: - Auth Error Types
enum AuthError: Error {
    case invalidCredentials
    case networkError(Error)
    case unknown
}

extension AuthError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid credentials"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}
