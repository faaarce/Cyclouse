//
//  ResetViewController.swift
//  Cyclouse
//
//  Created by yoga arie on 29/06/25.
//


import UIKit
import SnapKit
import Combine
import CombineCocoa

class ResetViewController: BaseViewController {
    
    // MARK: - Properties
    var coordinator: ResetCoordinator
    private let viewModel: ResetViewModel
    
    // MARK: - UI Components
    private let passwordInputView = CustomInputFieldView(
        labelText: "Password",
        placeholder: "Enter your password",
        isPassword: true
    )
    
    private let confirmPasswordInputView = CustomInputFieldView(
        labelText: "Confirm Password",
        placeholder: "Enter your password",
        isPassword: true
    )
    
    private let saveButton: UIButton = {
        ButtonFactory.build(
            title: "Save",
            font: ThemeFont.semibold(ofSize: 14)
        )
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "The password must be different than before."
        label.font = ThemeFont.regular(ofSize: 14)
        label.textColor = ThemeColor.labelColor
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    private let requirementsLabel: UILabel = {
        let label = UILabel()
        label.text = "• At least 8 characters\n• Include uppercase and lowercase letters\n• Include at least one number"
        label.font = ThemeFont.regular(ofSize: 12)
        label.textColor = ThemeColor.labelColorSecondary
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    // MARK: - Initialization
    init(coordinator: ResetCoordinator, viewModel: ResetViewModel) {
        self.coordinator = coordinator
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        configureAppearance()
        layout()
        setupBindings() // Uncommented this method call
        setupKeyboardDismissal()
    }
    
    
    // MARK: - Setup Methods
    private func configureAppearance() {
        title = "Reset Password"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        view.backgroundColor = ThemeColor.background
    }
    
    override func setupViews() {
        [infoLabel, passwordInputView, confirmPasswordInputView, requirementsLabel, saveButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func setupKeyboardDismissal() {
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
  
  // MARK: - Bindings
      private func setupBindings() {
          // Bind password text field to view model
          passwordInputView.textField.textPublisher
              .compactMap { $0 }
              .assign(to: \.newPassword, on: viewModel)
              .store(in: &cancellables)
              
          // Bind confirm password text field to view model
          confirmPasswordInputView.textField.textPublisher
              .compactMap { $0 }
              .assign(to: \.confirmPassword, on: viewModel)
              .store(in: &cancellables)
              
          // Handle save button tap
          saveButton.tapPublisher
              .sink { [weak self] _ in
                  self?.viewModel.saveTapped.send()
              }
              .store(in: &cancellables)
              
          // Handle loading state
          viewModel.$isLoading
              .receive(on: DispatchQueue.main)
              .sink { [weak self] isLoading in
                  self?.updateLoadingState(isLoading)
              }
              .store(in: &cancellables)
              
          // Handle error messages
          viewModel.errorMessage
              .receive(on: DispatchQueue.main)
              .sink { [weak self] message in
                  self?.presentErrorAlert(message: message)
              }
              .store(in: &cancellables)
              
          // Handle success navigation
          viewModel.resetSuccess
              .receive(on: DispatchQueue.main)
              .sink { [weak self] _ in
                  self?.handleResetSuccess()
              }
              .store(in: &cancellables)
              
          // Handle password validation UI updates
          viewModel.isPasswordValidSubject
              .receive(on: DispatchQueue.main)
              .sink { [weak self] isValid in
                  self?.updatePasswordField(isValid: isValid)
              }
              .store(in: &cancellables)
              
          // Handle confirm password validation UI updates
          viewModel.passwordsMatchSubject
              .receive(on: DispatchQueue.main)
              .sink { [weak self] doMatch in
                  self?.updateConfirmPasswordField(doMatch: doMatch)
              }
              .store(in: &cancellables)
              
          // Update save button state based on form validity
          viewModel.$newPassword
              .combineLatest(viewModel.$confirmPassword)
              .map { password, confirmPassword in
                  return !password.isEmpty && password.count >= 8 && password == confirmPassword
              }
              .receive(on: DispatchQueue.main)
              .assign(to: \.isEnabled, on: saveButton)
              .store(in: &cancellables)
      }

   
    // MARK: - UI Updates
    private func updatePasswordField(isValid: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.passwordInputView.textField.layer.borderWidth = isValid ? 0.0 : 1.0
            self.passwordInputView.textField.layer.borderColor = isValid ? UIColor.clear.cgColor : UIColor.red.cgColor
        }
    }
    
    private func updateConfirmPasswordField(doMatch: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.confirmPasswordInputView.textField.layer.borderWidth = doMatch ? 0.0 : 1.0
            self.confirmPasswordInputView.textField.layer.borderColor = doMatch ? UIColor.clear.cgColor : UIColor.red.cgColor
        }
    }
    
    private func updateLoadingState(_ isLoading: Bool) {
        if isLoading {
            presentLoadingView(message: "Resetting password...")
            saveButton.isEnabled = false
            saveButton.alpha = 0.6
        } else {
            dismissLoadingView()
            saveButton.isEnabled = true
            saveButton.alpha = 1.0
        }
    }
    
    private func presentErrorAlert(message: String) {
        // Dismiss any existing alerts first
        if presentedViewController != nil {
            dismiss(animated: false) {
                MessageAlert.showError(message: message)
            }
        } else {
            MessageAlert.showError(message: message)
        }
    }
    
    private func handleResetSuccess() {
        // Show success message
        presentSuccessMessage("Password reset successfully!")
        
        // Navigate back to login after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            // Option 1: Use coordinator to handle navigation
//            self?.coordinator.delegate?.resetCoordinatorDidFinish(self?.coordinator ?? ResetCoordinator(navigationController: UINavigationController(), container: Container()))
            
            // Option 2: Pop to root (login screen)
            // self?.navigationController?.popToRootViewController(animated: true)
          
          
          /*
           their data
           NotificationCenter.default.post(name: Notification.Name.paymentCompleted, object: nil)
           
           // Clean up current coordinator
           coordinator.didFinish()
           
           // Dismiss this view controller and pop to root
           dismiss(animated: true) { [weak self] in
             self?.navigationController?.popToRootViewController(animated: true)
             
             // Find the tab bar controller and switch to home tab
             if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let window = windowScene.windows.first,
                let tabBarController = window.rootViewController as? UITabBarController {
               tabBarController.selectedIndex = 0 // Switch to home tab
             }
           }
           */
          self?.coordinator.didFinish()
          self?.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    private func presentSuccessMessage(_ message: String) {
        MessageAlert.showSuccess(message: message)
    }
    
    // MARK: - Layout
    private func layout() {
        // Info label at the top
        infoLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.leading.equalToSuperview().offset(20)  // Leading margin = 20
            $0.trailing.equalToSuperview().offset(-20) // Trailing margin = 20
        }
        
        // Password input field
        passwordInputView.snp.makeConstraints {
            $0.top.equalTo(infoLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(20)   // Leading margin = 20
            $0.trailing.equalToSuperview().offset(-20)  // Trailing margin = 20
        }
        
        // Confirm password input field
        confirmPasswordInputView.snp.makeConstraints {
            $0.top.equalTo(passwordInputView.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)   // Leading margin = 20
            $0.trailing.equalToSuperview().offset(-20)  // Trailing margin = 20
        }
        
        // Requirements label
        requirementsLabel.snp.makeConstraints {
            $0.top.equalTo(confirmPasswordInputView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)   // Leading margin = 20
            $0.trailing.equalToSuperview().offset(-20)  // Trailing margin = 20
        }
        
        // Save button
        saveButton.snp.makeConstraints {
            $0.top.equalTo(requirementsLabel.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(20)   // Leading margin = 20
            $0.trailing.equalToSuperview().offset(-20)  // Trailing margin = 20
            $0.height.equalTo(48) // Standard button height
        }
    }
}


