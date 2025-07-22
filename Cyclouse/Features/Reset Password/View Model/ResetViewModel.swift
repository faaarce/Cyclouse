//
//  ResetViewModel.swift
//  Cyclouse
//
//  Created by yoga arie on 30/06/25.
//

import Foundation
import UIKit
import Combine

class ResetViewModel: ObservableObject {
    // MARK: - Properties
    let email: String
    let code: String

    @Published var newPassword = ""
    @Published var confirmPassword = ""
    @Published var isLoading = false
    
    // MARK: - Publishers
    let saveTapped = PassthroughSubject<Void, Never>()
    let errorMessage = PassthroughSubject<String, Never>()
    let resetSuccess = PassthroughSubject<Void, Never>()
    let isPasswordValidSubject = PassthroughSubject<Bool, Never>()
    let passwordsMatchSubject = PassthroughSubject<Bool, Never>()
    
    // MARK: - Dependencies
    private let authenticationService: AuthenticationService
    private var cancellables = Set<AnyCancellable>()

    // Updated initializer to accept email and code from the coordinator
    init(authenticationService: AuthenticationService = AuthenticationService(), email: String, code: String) {
        self.authenticationService = authenticationService
        self.email = email
        self.code = code
        setupBindings()
    }

    private func setupBindings() {
        saveTapped
            .sink { [weak self] in
                self?.validateAndReset()
            }
            .store(in: &cancellables)
    }

    private func validateAndReset() {
        let isPasswordValid = newPassword.count >= 8
        let passwordsMatch = newPassword == confirmPassword && !newPassword.isEmpty

        // Provide feedback to the UI
        isPasswordValidSubject.send(isPasswordValid)
        passwordsMatchSubject.send(passwordsMatch)

        // Check conditions before proceeding
        guard isPasswordValid, passwordsMatch else {
            var errorMsg = ""
            if !isPasswordValid {
                errorMsg += "Password must be at least 8 characters.\n"
            }
            if !passwordsMatch {
                errorMsg += "Passwords do not match."
            }
            errorMessage.send(errorMsg.trimmingCharacters(in: .whitespacesAndNewlines))
            return
        }

        performReset()
    }

    private func performReset() {
        isLoading = true
        // Assumes `resetPassword` exists on your service and returns a Publisher
      authenticationService.reset(email: email, code: code, newPassword: newPassword)
            .sink { [weak self] completion in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage.send(error.localizedDescription)
                    }
                }
            } receiveValue: { [weak self] _ in
                DispatchQueue.main.async {
                    self?.resetSuccess.send()
                }
            }
            .store(in: &cancellables)
    }
}
