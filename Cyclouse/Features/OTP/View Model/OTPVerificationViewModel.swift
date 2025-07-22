//
//  OTPVerificationViewModel.swift
//  Cyclouse
//
//  Created by yoga arie on 29/06/25.
//

import Foundation
import Combine

class OTPVerificationViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var otp: String = ""
    @Published var isLoading = false
    let email: String // Add email property
    
    // MARK: - Subjects
    let verifyTapped = PassthroughSubject<Void, Never>()
    let resendCodeTapped = PassthroughSubject<Void, Never>()
    let errorMessage = PassthroughSubject<String, Never>()
    let verificationSuccess = PassthroughSubject<Void, Never>()
    let resendSuccess = PassthroughSubject<Void, Never>()
    let isOTPValidSubject = PassthroughSubject<Bool, Never>()
    
    // MARK: - Dependencies
    private var cancellables = Set<AnyCancellable>()
    private let authenticationService: AuthenticationService
    
    // MARK: - Initialization
    init(email: String, authenticationService: AuthenticationService = AuthenticationService()) {
        self.email = email // Store the email
        self.authenticationService = authenticationService
        setupBindings()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        // Handle verify button tap
        verifyTapped
            .sink { [weak self] _ in
                self?.verifyOTP()
            }
            .store(in: &cancellables)
        
        // Handle resend button tap
        resendCodeTapped
            .sink { [weak self] _ in
                self?.resendCode()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Verification Logic
    private func verifyOTP() {
        // Validate OTP format
        let isValid = otp.count == 4 && otp.allSatisfy { $0.isNumber }
        isOTPValidSubject.send(isValid)
        
        if !isValid {
            errorMessage.send("Please enter a valid 4-digit code")
            return
        }
        
        // Start verification
        isLoading = true
        
        // Call the actual verification API
        authenticationService.verify(email: email, code: otp)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    
                    if case .failure(let error) = completion {
                        self?.errorMessage.send("Verification failed. Please try again.")
                        print("Verification error: \(error)")
                    }
                },
                receiveValue: { [weak self] response in
                    if response.value.success {
                        self?.verificationSuccess.send()
                    } else {
                        let message = response.value.message ?? "Invalid verification code. Please try again."
                        self?.errorMessage.send(message)
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Resend Logic
    private func resendCode() {
        isLoading = true
        
        // Call the forgot API again to resend the code
        authenticationService.forgot(email: email)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    
                    if case .failure(let error) = completion {
                        self?.errorMessage.send("Failed to resend code. Please try again.")
                        print("Resend error: \(error)")
                    }
                },
                receiveValue: { [weak self] response in
                    if response.value.success {
                        self?.resendSuccess.send()
                    } else {
                        let message = response.value.message ?? "Failed to resend code. Please try again."
                        self?.errorMessage.send(message)
                    }
                }
            )
            .store(in: &cancellables)
    }
}
