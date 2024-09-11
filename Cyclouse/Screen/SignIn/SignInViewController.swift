//
//  SignInViewController.swift
//  Cyclouse
//
//  Created by yoga arie on 05/09/24.
//
import SnapKit
import UIKit
import AuthenticationServices

class SignInViewController: UIViewController {
  
  var coordinator: SignInCoordinator
  private let emailInputView = CustomInputFieldView(labelText: "Email", placeholder: "Input Email")
  private let passwordInputView = CustomInputFieldView(labelText: "Password", placeholder: "Input Password")
  
  private let forgotPasswordButton: UIButton = {
    let object = UIButton()
    object.titleLabel?.font = ThemeFont.semibold(ofSize: 12)
    object.setTitle("Forgot Password", for: .normal)
    object.setTitleColor(ThemeColor.primary, for: .normal)
    return object
  }()
  
  private lazy var loginButton: UIButton = {
    let button = ButtonFactory.build(
      title: "Login",
      font: ThemeFont.semibold(ofSize: 14)
    )
    return button
  }()
  
  private lazy var appleLoginButton: ASAuthorizationAppleIDButton = {
    let button = ASAuthorizationAppleIDButton()
    button.addTarget(self, action: #selector(handleLogInWithAppleID), for: .touchUpInside)
    return button
  }()
  
  private let signUpLabel: UILabel = {
    LabelFactory.build(
      text: "Don't have an account?",
      font: ThemeFont.medium(ofSize: 14),
      textColor: ThemeColor.labelColor,
      textAlignment: .left
    )
  }()
  
  private let signUpButton: UIButton = {
    let object = UIButton()
    object.titleLabel?.font = ThemeFont.semibold(ofSize: 14)
    object.setTitle("Sign Up", for: .normal)
    object.setTitleColor(ThemeColor.primary, for: .normal)
    return object
  }()
  
  
  private lazy var hSignUpStackView: UIStackView = {
    let view = UIStackView(arrangedSubviews: [
      signUpLabel,
      signUpButton
    ])
    view.axis = .horizontal
    view.spacing = 4
    view.distribution = .fill
    view.alignment = .fill
    return view
    
  }()
  
  private let separatorLabel: UILabel = {
    LabelFactory.build(
      text: "Or With",
      font: ThemeFont.semibold(ofSize: 14),
      textColor: ThemeColor.labelColor,
      textAlignment: .center
    )
  }()
  
  private lazy var vSignInStackView: UIStackView = {
    let view = UIStackView(arrangedSubviews: [
      loginButton,
      separatorLabel,
      appleLoginButton
    ])
    view.axis = .vertical
    view.spacing = 10
    view.distribution = .fillEqually
    view.alignment = .fill
    return view
  }()
  
  init(coordinator: SignInCoordinator) {
    self.coordinator = coordinator
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
    configureAppearance()
    layout()
  }
  
  private func configureAppearance() {
    title = "Sign In"
    view.backgroundColor = ThemeColor.background
  }
  
  @objc func handleLogInWithAppleID() {
    print("Test")
  }
  
  private func setupViews() {
    [emailInputView, passwordInputView, forgotPasswordButton, hSignUpStackView, vSignInStackView].forEach(view.addSubview)
  }
  
  
  private func layout() {
    
    loginButton.snp.makeConstraints {
      $0.height.equalTo(42)
    }
    
    appleLoginButton.snp.makeConstraints {
      $0.height.equalTo(42)
    }
    
    emailInputView.snp.makeConstraints { make in
      make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(40)
      make.left.equalToSuperview().offset(20)
      make.right.equalToSuperview().offset(-20)
      make.centerX.equalToSuperview()
    }
    
    passwordInputView.snp.makeConstraints { make in
      make.top.equalTo(emailInputView.snp.bottom).offset(16)
      make.left.equalToSuperview().offset(20)
      make.right.equalToSuperview().offset(-20)
      make.centerX.equalToSuperview()
    }
    
    forgotPasswordButton.snp.makeConstraints {
      $0.top.equalTo(passwordInputView.snp.bottom).offset(16)
      $0.right.equalToSuperview().offset(-20)
    }

    hSignUpStackView.snp.makeConstraints {
      $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-12)
      $0.centerX.equalToSuperview()
    }
    
    vSignInStackView.snp.makeConstraints {
      $0.top.equalTo(passwordInputView.snp.bottom).offset(85)
      $0.left.equalToSuperview().offset(20)
      $0.right.equalToSuperview().offset(-20)
    }
   
  }
  
}
