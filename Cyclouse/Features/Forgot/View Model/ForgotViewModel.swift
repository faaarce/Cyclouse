import Foundation
import UIKit
import Combine

class ForgotViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var email: String = "" // Removed optional to simplify binding
    @Published var isLoading = false
    
    // MARK: - Subjects for Communication
    let continueTapped = PassthroughSubject<Void, Never>()
    let errorMessage = PassthroughSubject<String, Never>()
    let continueSuccess = PassthroughSubject<String, Never>() // Changed to pass email for next screen
    let isEmailValidSubject = PassthroughSubject<Bool, Never>()
    
    // MARK: - Dependencies
    private var cancellables = Set<AnyCancellable>()
    private let authenticationService: AuthenticationService
    
    init(authenticationService: AuthenticationService = AuthenticationService()) {
        self.authenticationService = authenticationService
        setupBindings()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        // Listen for continue button taps
        continueTapped
            .sink { [weak self] _ in
                self?.validateAndProceed()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Validation
    private func validateAndProceed() {
        // Trim whitespace to prevent issues with accidental spaces
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if email is valid using the extension
        let isEmailValid = trimmedEmail.isValidEmail
        
        // Send validation status to update UI
        isEmailValidSubject.send(isEmailValid)
        
        // If invalid, show error and stop
        if !isEmailValid {
            errorMessage.send("Please enter a valid email address.")
            return
        }
        
        // If validation passes, proceed with the API call
        forgotPassword(email: trimmedEmail)
    }
    
    // MARK: - API Call
    private func forgotPassword(email: String) {
        // Start loading
        isLoading = true
        
        // Call the authentication service
        authenticationService.forgot(email: email)
            .receive(on: DispatchQueue.main) // Ensure UI updates happen on main thread
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }
                    
                    // Always stop loading when request completes
                    self.isLoading = false
                    
                    // Handle errors
                    if case .failure(let error) = completion {
                        self.handleError(error)
                    }
                },
                receiveValue: { [weak self] response in
                    guard let self = self else { return }
                    
                    // Check if the API response indicates success
                    if response.value.success {
                        // Send success with email so next screen knows which email to verify
                        self.continueSuccess.send(email)
                    } else {
                        // Handle API-level failure (success = false)
                        let message = response.value.message ?? "Failed to send reset email. Please try again."
                        self.errorMessage.send(message)
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Error Handling
    private func handleError(_ error: Error) {
        // Create user-friendly error messages based on error type
        let message: String
        
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                message = "No internet connection. Please check your network and try again."
            case .timedOut:
                message = "Request timed out. Please try again."
            default:
                message = "Network error occurred. Please try again."
            }
        } else if error.localizedDescription.contains("Email") {
            // Handle validation errors from the service
            message = error.localizedDescription
        } else {
            // Generic error message
            message = "An error occurred. Please try again later."
        }
        
        errorMessage.send(message)
    }
}
