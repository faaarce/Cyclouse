//
//  ForgotViewController.swift
//  Cyclouse
//
//  Created by yoga arie on 25/06/25.
//
import SnapKit
import UIKit
import CombineCocoa
import Combine

class ForgotViewController: BaseViewController {
    
    // MARK: - Properties
    var coordinator: ForgotCoordinator
    private let viewModel: ForgotViewModel
    
    // MARK: - UI Components
    private let emailInputView = CustomInputFieldView(
        labelText: "Email",
        placeholder: "Enter your email"
    )
    
    private let continueButton: UIButton = {
        ButtonFactory.build(
            title: "Continue",
            font: ThemeFont.semibold(ofSize: 14)
        )
    }()
    
    // Info label to guide users
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter email account to reset your password."
        label.font = ThemeFont.regular(ofSize: 14)
        label.textColor = ThemeColor.labelColor
        label.numberOfLines = 0
      label.textAlignment = .left
        return label
    }()
    
    // MARK: - Initialization
    init(coordinator: ForgotCoordinator, viewModel: ForgotViewModel) {
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
        layout()
        configureAppearance()
        setupBindings()
        setupKeyboardDismissal()
    }
    
    // MARK: - Setup Methods
    private func configureAppearance() {
        title = "Forgot Password"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        view.backgroundColor = ThemeColor.background
    }
    
    override func setupViews() {
        [infoLabel, emailInputView, continueButton].forEach(view.addSubview)
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
        // Bind button tap to view model
        continueButton.tapPublisher
            .sink { [weak self] _ in
                self?.viewModel.continueTapped.send()
            }
            .store(in: &cancellables)
        
        // Bind text field to view model's email property
        emailInputView.textField.textPublisher
            .replaceNil(with: "") // Convert nil to empty string
            .removeDuplicates() // Prevent unnecessary updates
            .assign(to: \.email, on: viewModel)
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
        
        // Handle success - navigate to OTP/verification screen
        viewModel.continueSuccess
            .receive(on: DispatchQueue.main)
            .sink { [weak self] email in
                // Pass the email to coordinator so OTP screen knows which email to verify
//                self?.coordinator.showOTPVerification(email: email)
              DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self?.coordinator.navigateToVerificationScreen(email)
                                }
            }
            .store(in: &cancellables)
            
        // Handle email validation UI updates
        viewModel.isEmailValidSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isValid in
                self?.updateEmailField(isValid: isValid)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - UI Updates
    private func updateEmailField(isValid: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.emailInputView.textField.layer.borderWidth = isValid ? 0.0 : 1.0
            self.emailInputView.textField.layer.borderColor = isValid ? UIColor.clear.cgColor : UIColor.red.cgColor
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
    
    private func updateLoadingState(_ isLoading: Bool) {
        if isLoading {
            presentLoadingView(message: "Sending reset instructions...")
            continueButton.isEnabled = false
            continueButton.alpha = 0.6
        } else {
            dismissLoadingView()
            continueButton.isEnabled = true
            continueButton.alpha = 1.0
        }
    }
    
    // MARK: - Layout
    private func layout() {
        infoLabel.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
        }
        
        emailInputView.snp.makeConstraints {
            $0.top.equalTo(infoLabel.snp.bottom).offset(16)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
        }
        
        continueButton.snp.makeConstraints {
            $0.top.equalTo(emailInputView.snp.bottom).offset(32)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.height.equalTo(48) // Slightly taller for better touch target
        }
    }
}
