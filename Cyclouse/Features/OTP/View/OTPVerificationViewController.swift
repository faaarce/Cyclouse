//
//  OTPVerificationViewController.swift
//  Cyclouse
//
//  Created by yoga arie on 29/06/25.
//
import UIKit
import SnapKit
import Combine
import CombineCocoa

class OTPVerificationViewController: BaseViewController {
    
    // MARK: - Properties
  var coordinator: OTPCoordinator
    private let viewModel: OTPVerificationViewModel
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter Verification Code"
        label.font = ThemeFont.bold(ofSize: 28)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.regular(ofSize: 16)
        label.textColor = ThemeColor.labelColor
        label.numberOfLines = 0
        label.textAlignment = .center
        
        // We'll set the attributed text in viewDidLoad to handle the email color
        return label
    }()
    
    // Container for OTP input fields
    private let otpStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        return stackView
    }()
    
    // Array to hold our OTP text fields
    private var otpTextFields: [OTPTextField] = []
    
    private let verifyButton: UIButton = {
        let button = ButtonFactory.build(
            title: "Verify Now",
            font: ThemeFont.semibold(ofSize: 16)
        )
        button.backgroundColor = ThemeColor.primary
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    private let resendContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.alignment = .center
        return stackView
    }()
    
    private let didntReceiveLabel: UILabel = {
        let label = UILabel()
        label.text = "Didn't you receive any code?"
        label.font = ThemeFont.regular(ofSize: 14)
        label.textColor = ThemeColor.labelColor
        return label
    }()
    
    private let resendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Resend Code", for: .normal)
        button.titleLabel?.font = ThemeFont.semibold(ofSize: 14)
        button.setTitleColor(ThemeColor.primary, for: .normal)
        return button
    }()
    
    // Timer for resend functionality
    private var resendTimer: Timer?
    private var resendCountdown: Int = 0
    
    // MARK: - Initialization
  init(coordinator: OTPCoordinator, viewModel: OTPVerificationViewModel) {
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
        createOTPFields()
        layout()
        setupBindings()
//        configureSubtitleWithEmail()
        
        // Auto-focus first field
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.otpTextFields.first?.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        resendTimer?.invalidate()
    }
    
    // MARK: - Setup Methods
    private func configureAppearance() {
        title = "Verification"
        view.backgroundColor = ThemeColor.background
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func setupViews() {
        [titleLabel, subtitleLabel, otpStackView, verifyButton, resendContainer].forEach {
            view.addSubview($0)
        }
        
        [didntReceiveLabel, resendButton].forEach {
            resendContainer.addArrangedSubview($0)
        }
    }
    
    private func configureSubtitleWithEmail() {
        let fullText = "We have to sent a code to\n\(viewModel.email)"
        let attributedString = NSMutableAttributedString(string: fullText)
        
        // Style the entire string with default color
        attributedString.addAttribute(.foregroundColor,
                                    value: ThemeColor.labelColor,
                                    range: NSRange(location: 0, length: fullText.count))
        
        // Style the email in green
        if let emailRange = fullText.range(of: viewModel.email) {
            let nsRange = NSRange(emailRange, in: fullText)
            attributedString.addAttribute(.foregroundColor,
                                        value: ThemeColor.primary,
                                        range: nsRange)
        }
        
        subtitleLabel.attributedText = attributedString
    }
    
    private func createOTPFields() {
        // Create 4 OTP text fields
        for i in 0..<4 {
            let textField = OTPTextField()
            textField.tag = i
            textField.delegate = self
            textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            
            otpTextFields.append(textField)
            otpStackView.addArrangedSubview(textField)
        }
    }
    
    // MARK: - Bindings
  private func setupBindings() {
    // Verify button tap
    verifyButton.tapPublisher
      .sink { [weak self] _ in
        self?.handleVerifyTap()
      }
      .store(in: &cancellables)
    
    // Resend button tap
    resendButton.tapPublisher
      .sink { [weak self] _ in
        self?.viewModel.resendCodeTapped.send()
      }
      .store(in: &cancellables)
    
    // Loading state
    viewModel.$isLoading
      .receive(on: DispatchQueue.main)
      .sink { [weak self] isLoading in
        self?.updateLoadingState(isLoading)
      }
      .store(in: &cancellables)
    
    // Error messages
    viewModel.errorMessage
      .receive(on: DispatchQueue.main)
      .sink { [weak self] message in
        self?.presentErrorAlert(message: message)
      }
      .store(in: &cancellables)
    
    // Success navigation
    viewModel.verificationSuccess
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _ in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { 
        self?.coordinator.navigateToResetScreen() //ERROR
      }
  }
            .store(in: &cancellables)
        
        // Resend success
        viewModel.resendSuccess
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.handleResendSuccess()
            }
            .store(in: &cancellables)
        
        // OTP validation state
        viewModel.isOTPValidSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isValid in
                self?.updateOTPFieldsValidation(isValid: isValid)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    private func handleVerifyTap() {
        // Collect OTP from all fields
        let otp = otpTextFields.map { $0.text ?? "" }.joined()
        viewModel.otp = otp
        viewModel.verifyTapped.send()
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        // Handle paste functionality
        if text.count > 1 {
            handlePastedOTP(text)
            return
        }
        
        // Normal single character input
        if text.count == 1 {
            // Move to next field
            if textField.tag < 3 {
                otpTextFields[textField.tag + 1].becomeFirstResponder()
            } else {
                // Last field filled, trigger verification
                textField.resignFirstResponder()
                handleVerifyTap()
            }
        }
        
        // Update the combined OTP in view model
        let otp = otpTextFields.map { $0.text ?? "" }.joined()
        viewModel.otp = otp
    }
    
    private func handlePastedOTP(_ pastedText: String) {
        // Take only first 4 characters
        let otp = String(pastedText.prefix(4))
        
        // Distribute characters to fields
        for (index, char) in otp.enumerated() {
            if index < otpTextFields.count {
                otpTextFields[index].text = String(char)
            }
        }
        
        // Focus on the last filled field or the last field if all are filled
        let lastFilledIndex = min(otp.count - 1, 3)
        otpTextFields[lastFilledIndex].becomeFirstResponder()
        
        // If all fields are filled, trigger verification
        if otp.count == 4 {
            handleVerifyTap()
        }
    }
    
    // MARK: - UI Updates
    private func updateLoadingState(_ isLoading: Bool) {
        if isLoading {
            presentLoadingView(message: "Verifying code...")
            verifyButton.isEnabled = false
            verifyButton.alpha = 0.6
        } else {
            dismissLoadingView()
            verifyButton.isEnabled = true
            verifyButton.alpha = 1.0
        }
    }
    
    private func updateOTPFieldsValidation(isValid: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.otpTextFields.forEach { textField in
                textField.layer.borderColor = isValid ? ThemeColor.primary.cgColor : UIColor.red.cgColor
            }
        }
    }
    
    private func handleResendSuccess() {
        // Show success message
        presentSuccessMessage("Code sent successfully!")
        
        // Clear OTP fields
        otpTextFields.forEach { $0.text = "" }
        otpTextFields.first?.becomeFirstResponder()
        
        // Start countdown
        startResendCountdown()
    }
    
    private func startResendCountdown() {
        resendCountdown = 60 // 60 seconds countdown
        resendButton.isEnabled = false
        
        resendTimer?.invalidate()
        resendTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateResendCountdown()
        }
    }
    
    private func updateResendCountdown() {
        resendCountdown -= 1
        
        if resendCountdown > 0 {
            resendButton.setTitle("Resend Code (\(resendCountdown)s)", for: .disabled)
            resendButton.alpha = 0.6
        } else {
            resendTimer?.invalidate()
            resendButton.setTitle("Resend Code", for: .normal)
            resendButton.isEnabled = true
            resendButton.alpha = 1.0
        }
    }
    
    private func presentErrorAlert(message: String) {
        if presentedViewController != nil {
            dismiss(animated: false) {
                MessageAlert.showError(message: message)
            }
        } else {
            MessageAlert.showError(message: message)
        }
    }
    
    private func presentSuccessMessage(_ message: String) {
        // You can implement a toast or success alert here
        MessageAlert.showSuccess(message: message)
    }
    
    // MARK: - Layout
    private func layout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
        }
        
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.left.equalToSuperview().offset(40)
            $0.right.equalToSuperview().offset(-40)
        }
        
        otpStackView.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(60)
            $0.centerX.equalToSuperview()
            $0.left.greaterThanOrEqualToSuperview().offset(40)
            $0.right.lessThanOrEqualToSuperview().offset(-40)
            $0.height.equalTo(56)
        }
        
        // Set width constraint for each OTP field
        otpTextFields.forEach { textField in
            textField.snp.makeConstraints {
                $0.width.equalTo(56)
            }
        }
        
        verifyButton.snp.makeConstraints {
            $0.top.equalTo(otpStackView.snp.bottom).offset(60)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.height.equalTo(56)
        }
        
        resendContainer.snp.makeConstraints {
            $0.top.equalTo(verifyButton.snp.bottom).offset(24)
            $0.centerX.equalToSuperview()
        }
    }
}

// MARK: - UITextFieldDelegate
extension OTPVerificationViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Handle backspace
        if string.isEmpty {
            textField.text = ""
            
            // Move to previous field if current is empty
            if textField.tag > 0 {
                otpTextFields[textField.tag - 1].becomeFirstResponder()
            }
            
            // Update view model
            let otp = otpTextFields.map { $0.text ?? "" }.joined()
            viewModel.otp = otp
            
            return false
        }
        
        // Allow only numeric input
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Highlight active field
        textField.layer.borderColor = ThemeColor.primary.cgColor
        textField.layer.borderWidth = 2.0
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Remove highlight
      textField.layer.borderColor = UIColor.gray.cgColor
        textField.layer.borderWidth = 1.0
    }
}

// MARK: - Custom OTP TextField
class OTPTextField: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    private func configure() {
        // Basic configuration
      backgroundColor = ThemeColor.cardFillColor
        textColor = .white
        font = ThemeFont.bold(ofSize: 24)
        textAlignment = .center
        keyboardType = .numberPad
        
        // Border styling
        layer.cornerRadius = 12
        layer.borderWidth = 1.0
      layer.borderColor = UIColor.gray.cgColor
        
        // Limit to 1 character
        addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    @objc private func textDidChange() {
        // Ensure only 1 character
        if let text = text, text.count > 1 {
            self.text = String(text.prefix(1))
        }
    }
    
    // Override to prevent selection and show cursor in center
    override func caretRect(for position: UITextPosition) -> CGRect {
        let rect = super.caretRect(for: position)
        return CGRect(x: bounds.width / 2 - rect.width / 2,
                      y: rect.origin.y,
                      width: rect.width,
                      height: rect.height)
    }
    
    // Disable paste menu for cleaner UX (paste still works programmatically)
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(paste(_:)) {
            return true
        }
        return false
    }
}

extension OTPVerificationViewController {
//    // Add this method back to your viewDidLoad
//    private func configureSubtitleWithEmail() {
//        let fullText = "We have to sent a code to\n\(viewModel.email)"
//        let attributedString = NSMutableAttributedString(string: fullText)
//        
//        // Style the entire string with default color
//        attributedString.addAttribute(.foregroundColor,
//                                    value: ThemeColor.labelColor,
//                                    range: NSRange(location: 0, length: fullText.count))
//        
//        // Style the email in green
//        if let emailRange = fullText.range(of: viewModel.email) {
//            let nsRange = NSRange(emailRange, in: fullText)
//            attributedString.addAttribute(.foregroundColor,
//                                        value: ThemeColor.primary,
//                                        range: nsRange)
//        }
//        
//        subtitleLabel.attributedText = attributedString
//    }
}
