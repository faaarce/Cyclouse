//
//  SignUpViewController.swift
//  Cyclouse
//
//  Created by yoga arie on 20/09/24.
//
import SnapKit
import UIKit
import PhoneNumberKit
import CombineCocoa

class SignUpViewController: BaseViewController {
  private var authenticationManager = AuthenticationService()
  var coordinator: SignUpCoordinator
  private let viewModel: SignUpViewModel
  
  private let nameInputView = CustomInputFieldView(labelText: "Name", placeholder: "Enter your name")
  private let emailInputView = CustomInputFieldView(labelText: "Email", placeholder: "Enter your email")
  private let phoneInputView = CustomPhoneInputFieldView(labelText: "Phone")
  private let passwordInputView = CustomInputFieldView(labelText: "Password", placeholder: "Enter your password", isPassword: true)
  private let confirmPasswordInputView = CustomInputFieldView(labelText: "Confirm Password", placeholder: "Enter your password", isPassword: true)
  
  private let signupButton: UIButton = {
    ButtonFactory.build(title: "Sign Up", font: ThemeFont.semibold(ofSize: 14))
  }()
  
  private let loginLabel: UILabel = {
    LabelFactory.build(text: "Already have an account?", font: ThemeFont.medium(ofSize: 14), textColor: ThemeColor.labelColor, textAlignment: .left)
  }()
  
  private let loginButton: UIButton = {
    let object = UIButton()
    object.titleLabel?.font = ThemeFont.semibold(ofSize: 14)
    object.setTitle("Login", for: .normal)
    object.setTitleColor(ThemeColor.primary, for: .normal)
    object.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
    return object
  }()
  
  @objc func signUpButtonTapped() {
    coordinator.didFinishSignUp()
  }
  
  private lazy var hLoginStackView: UIStackView = {
    let view = UIStackView(arrangedSubviews: [
      loginLabel,
      loginButton
    ])
    view.axis = .horizontal
    view.spacing = 4
    view.distribution = .fill
    view.alignment = .fill
    return view
  }()
  
  init(coordinator: SignUpCoordinator, viewModel: SignUpViewModel) {
    self.coordinator = coordinator
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
    layout()
    configureAppearance()
    setupTextFieldTags()
    setupBindings()
  }
  
  private func setupTextFieldTags() {
    // Set tags for keyboard navigation order
    nameInputView.textField.tag = 1
    emailInputView.textField.tag = 2
    phoneInputView.getPhoneTextField.tag = 3
    passwordInputView.textField.tag = 4
    confirmPasswordInputView.textField.tag = 5
  }
  
  
  private func configureAppearance() {
    title = "Sign Up"
    view.backgroundColor = ThemeColor.background
    phoneInputView.applyTheme()
  }
  
  
  override func setupViews() {
    [nameInputView, emailInputView, phoneInputView, passwordInputView,
     confirmPasswordInputView, signupButton, hLoginStackView].forEach(view.addSubview)
  }
  
  private func setupBindings() {
    
    signupButton.tapPublisher
      .sink { [weak self] _ in
        self?.viewModel.signUpTapped.send()
      }
      .store(in: &cancellables)
    
    emailInputView.textField.textPublisher
      .assign(to: \.email, on: viewModel)
      .store(in: &cancellables)
    
    passwordInputView.textField.textPublisher
      .assign(to: \.password, on: viewModel)
      .store(in: &cancellables)
    
    phoneInputView.getPhoneTextField.textPublisher
      .assign(to: \.phoneNumber, on: viewModel)
      .store(in: &cancellables)
    
    phoneInputView.getPhoneTextField.textPublisher
      .sink { text in
          print("Phone number being typed: \(text)")
          self.viewModel.phoneNumber = text
      }
      .store(in: &cancellables)
    
    confirmPasswordInputView.textField.textPublisher
          .assign(to: \.confirmPassword, on: viewModel)
          .store(in: &cancellables)
    
    nameInputView.textField.textPublisher
      .assign(to: \.name, on: viewModel)
      .store(in: &cancellables)
    
    viewModel.$isLoading
      .receive(on: DispatchQueue.main)
      .sink { [weak self] isLoading in
        self?.updateLoadingState(isLoading)
      }
      .store(in: &cancellables)
    
    viewModel.errorMessage
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] message in
        self.presentErrorAlert(message: message)
      }
      .store(in: &cancellables)
    
    viewModel.updatePlaceholderColors
           .receive(on: DispatchQueue.main)
           .sink { [weak self] isNameValid, isEmailValid, isPasswordValid, isConfirmPasswordValid, isNumberValid in
               self?.updatePlaceholderColors(
                   isNameValid: isNameValid,
                   isEmailValid: isEmailValid,
                   isPasswordValid: isPasswordValid,
                   isConfirmPasswordValid: isConfirmPasswordValid,
                   isNumberValid: isNumberValid
               )
           }
           .store(in: &cancellables)
    
    viewModel.signUpSuccess
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _ in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9, execute: {
          self?.coordinator.didFinishSignUp()
          
        })
      }
      .store(in: &cancellables)
    
  }
  
  
  private func updatePlaceholderColors(
      isNameValid: Bool,
      isEmailValid: Bool,
      isPasswordValid: Bool,
      isConfirmPasswordValid: Bool,
      isNumberValid: Bool
  ) {
      nameInputView.textField.layer.borderWidth = isNameValid ? 0.0 : 1.0
      nameInputView.textField.layer.borderColor = isNameValid ? UIColor.clear.cgColor : UIColor.red.cgColor
      
      emailInputView.textField.layer.borderWidth = isEmailValid ? 0.0 : 1.0
      emailInputView.textField.layer.borderColor = isEmailValid ? UIColor.clear.cgColor : UIColor.red.cgColor
      
      passwordInputView.textField.layer.borderWidth = isPasswordValid ? 0.0 : 1.0
      passwordInputView.textField.layer.borderColor = isPasswordValid ? UIColor.clear.cgColor : UIColor.red.cgColor
      
      confirmPasswordInputView.textField.layer.borderWidth = isConfirmPasswordValid ? 0.0 : 1.0
      confirmPasswordInputView.textField.layer.borderColor = isConfirmPasswordValid ? UIColor.clear.cgColor : UIColor.red.cgColor
      
      phoneInputView.textField.layer.borderWidth = isNumberValid ? 0.0 : 1.0
      phoneInputView.textField.layer.borderColor = isNumberValid ? UIColor.clear.cgColor : UIColor.red.cgColor
  }
  
  
  private func presentErrorAlert(message: String) {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else {
        print("ViewController: Self is nil, cannot present alert")
        return
      }
      
      if self.presentedViewController != nil {
        print("ViewController: Another view controller is already presented, dismissing it")
        self.dismiss(animated: false) {
          MessageAlert.showError(message: message)
        }
      } else {
        MessageAlert.showError(message: message)
      }
    }
  }
  
  
  private func updateLoadingState(_ isLoading: Bool) {
    if isLoading {
      presentLoadingView(message: "Signing up...")
    } else {
      dismissLoadingView()
    }
  }


  
  private func layout() {
    nameInputView.snp.makeConstraints {
      $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(40)
      $0.left.equalToSuperview().offset(20)
      $0.right.equalToSuperview().offset(-20)
    }
    
    emailInputView.snp.makeConstraints {
      $0.top.equalTo(nameInputView.snp.bottom).offset(16)
      $0.left.equalToSuperview().offset(20)
      $0.right.equalToSuperview().offset(-20)
    }
    
    phoneInputView.snp.makeConstraints {
      $0.top.equalTo(emailInputView.snp.bottom).offset(16)
      $0.left.equalToSuperview().offset(20)
      $0.right.equalToSuperview().offset(-20)
    }
    
    passwordInputView.snp.makeConstraints {
      $0.top.equalTo(phoneInputView.snp.bottom).offset(16)
      $0.left.equalToSuperview().offset(20)
      $0.right.equalToSuperview().offset(-20)
    }
    
    confirmPasswordInputView.snp.makeConstraints {
      $0.top.equalTo(passwordInputView.snp.bottom).offset(16)
      $0.left.equalToSuperview().offset(20)
      $0.right.equalToSuperview().offset(-20)
    }
    
    signupButton.snp.makeConstraints {
      $0.top.equalTo(confirmPasswordInputView.snp.bottom).offset(50)
      $0.left.equalToSuperview().offset(20)
      $0.right.equalToSuperview().offset(-20)
      $0.height.equalTo(42)
    }
    
    hLoginStackView.snp.makeConstraints {
      $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-12)
      $0.centerX.equalToSuperview()
    }
  }
}
