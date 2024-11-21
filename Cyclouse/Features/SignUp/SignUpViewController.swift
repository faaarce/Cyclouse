//
//  SignUpViewController.swift
//  Cyclouse
//
//  Created by yoga arie on 20/09/24.
//
import SnapKit
import UIKit
import PhoneNumberKit

class SignUpViewController: BaseViewController {
    private var authenticationManager = AuthenticationService()
    var coordinator: SignUpCoordinator
    
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
        return object
    }()
    
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
    
    init(coordinator: SignUpCoordinator) {
        self.coordinator = coordinator
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
    
    @objc private func signUp() {
        guard let name = nameInputView.textField.text,
              let email = emailInputView.textField.text,
              let password = passwordInputView.textField.text,
              let confirmPassword = confirmPasswordInputView.textField.text,
              password == confirmPassword else {
            print("Validation failed")
            return
        }
        
        // Validate phone number
        guard phoneInputView.isValidPhoneNumber(),
              let formattedPhone = phoneInputView.getFormattedPhoneNumber() else {
            print("Invalid phone number")
            return
        }
        
        authenticationManager.signUp(name: name, email: email, password: password)
            .sink { [weak self] completionResult in
                switch completionResult {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                }
            } receiveValue: { [weak self] response in
                if response.value.success {
                    self?.coordinator.didFinishSignUp()
                }
            }
            .store(in: &cancellables)
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
