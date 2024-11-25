//
//  EditProfileViewController.swift
//  Cyclouse
//
//  Created by yoga arie on 25/11/24.
//
import UIKit
import SnapKit
import Combine

class EditProfileViewController: BaseViewController {
  private var editProfileService = UserProfileService()
  
  // MARK: - Properties
  private var userData: UserProfile
  var coordinator: EditProfileCoordinator
  private var isEditingProfile = false
  
  // MARK: - UI Components
  private lazy var mainStackView: UIStackView = {
    let stack = UIStackView()
    stack.axis = .vertical
    stack.spacing = 20
    stack.alignment = .fill
    stack.distribution = .fill
    stack.backgroundColor = .clear
    return stack
  }()
  
  private lazy var containerView: UIView = {
    let view = UIView()
    view.backgroundColor = ThemeColor.cardFillColor
    view.layer.cornerRadius = 12
    return view
  }()
  
  // Field Views
  private lazy var fullNameField = createProfileField(title: "Full Name", value: userData.name)
  private lazy var phoneField = createProfileField(title: "Phone Number", value: userData.name)
  private lazy var emailField = createProfileField(title: "Email", value: userData.email)
  
  // MARK: - Initialization
  init(coordinator: EditProfileCoordinator, userData: UserProfile) {
    self.userData = userData
    self.coordinator = coordinator
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Lifecycle Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
    setupConstraints()
    configureNavigationBar()
    addKeyboardObservers()
  }
  
  deinit {
    removeKeyboardObservers()
  }
  
  // MARK: - Setup Methods
  override func setupViews() {
    title = "Profile"
    view.backgroundColor = ThemeColor.background
    
    view.addSubview(containerView)
    containerView.addSubview(mainStackView)
    
    [fullNameField, phoneField, emailField].forEach { field in
      mainStackView.addArrangedSubview(field)
    }
  }
  
  override func setupConstraints() {
    containerView.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
      make.left.equalToSuperview().offset(20)
      make.right.equalToSuperview().offset(-20)
    }
    
    mainStackView.snp.makeConstraints { make in
      make.edges.equalToSuperview().inset(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
    }
  }
  
  private func configureNavigationBar() {
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "Edit",
      style: .plain,
      target: self,
      action: #selector(editButtonTapped)
    )
  }
  
  // MARK: - Helper Methods
  private func createProfileField(title: String, value: String) -> UIView {
    let containerView = UIView()
    
    let titleLabel = LabelFactory.build(
      text: title,
      font: ThemeFont.semibold(ofSize: 14),
      textColor: ThemeColor.labelColorSecondary,
      textAlignment: .left
    )
    titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    
    let valueLabel = LabelFactory.build(
      text: value,
      font: ThemeFont.semibold(ofSize: 14),
      textColor: .white
    )
    valueLabel.textAlignment = .right
    valueLabel.tag = 101  // Tag for easy access
    
    let textField = UITextField()
    textField.font = ThemeFont.semibold(ofSize: 14)
    textField.textColor = .white
    textField.textAlignment = .right
    textField.text = value
    textField.isHidden = true
    textField.tag = 100  // Tag for easy access
    textField.delegate = self  // Assign delegate for input validation
    
    let stackView = UIStackView(arrangedSubviews: [titleLabel, valueLabel, textField])
    stackView.axis = .horizontal
    stackView.spacing = 8
    stackView.alignment = .center
    stackView.distribution = .fill
    
    containerView.addSubview(stackView)
    
    stackView.snp.makeConstraints { make in
      make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0))
    }
    
    // Add bottom border
    let borderView = UIView()
    borderView.backgroundColor = ThemeColor.labelColorSecondary.withAlphaComponent(0.3)
    containerView.addSubview(borderView)
    
    borderView.snp.makeConstraints { make in
      make.left.right.bottom.equalToSuperview()
      make.height.equalTo(1)
    }
    
    return containerView
  }
  
  private func updateUIForEditingState() {
    [fullNameField, phoneField, emailField].forEach { field in
      let textField = field.viewWithTag(100) as? UITextField
      let label = field.viewWithTag(101) as? UILabel
      
      if isEditingProfile {
        textField?.alpha = 0
        textField?.isHidden = false
        UIView.animate(withDuration: 0.3) {
          textField?.alpha = 1
          label?.alpha = 0
        } completion: { _ in
          label?.isHidden = true
        }
      } else {
        label?.alpha = 0
        label?.isHidden = false
        UIView.animate(withDuration: 0.3) {
          label?.alpha = 1
          textField?.alpha = 0
        } completion: { _ in
          textField?.isHidden = true
        }
      }
    }
  }
  
  private func saveProfileChanges() {
    // Collect data from text fields
    let nameField = fullNameField.viewWithTag(100) as? UITextField
    let phoneField = phoneField.viewWithTag(100) as? UITextField
    let emailField = emailField.viewWithTag(100) as? UITextField
    
    guard let name = nameField?.text?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty,
          let phone = phoneField?.text?.trimmingCharacters(in: .whitespacesAndNewlines), !phone.isEmpty,
          let email = emailField?.text?.trimmingCharacters(in: .whitespacesAndNewlines), !email.isEmpty else {
      showMessage(title: "Error", body: "All fields are required.", theme: .error)
      isEditingProfile = true
      navigationItem.rightBarButtonItem?.title = "Save"
      updateUIForEditingState()
      return
    }
    
    // Validate email and phone formats
    guard isValidEmail(email) else {
      showMessage(title: "Error", body: "Please enter a valid email address.", theme: .error)
      isEditingProfile = true
      navigationItem.rightBarButtonItem?.title = "Save"
      updateUIForEditingState()
      return
    }
    
    guard isValidPhone(phone) else {
      showMessage(title: "Error", body: "Please enter a valid phone number.", theme: .error)
      isEditingProfile = true
      navigationItem.rightBarButtonItem?.title = "Save"
      updateUIForEditingState()
      return
    }
    
    MessageAlert.showLoading()
    
    editProfileService.editProfile(userId: userData.userId, name: name, phone: phone, email: email)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] completion in
        MessageAlert.hideLoading()
        
        switch completion {
        case .finished:
          break
        case .failure(let error):
          self?.showMessage(
            title: "Error",
            body: error.localizedDescription,
            theme: .error
          )
          // Revert to edit mode on error
          self?.isEditingProfile = true
          self?.navigationItem.rightBarButtonItem?.title = "Save"
          self?.updateUIForEditingState()
        }
      } receiveValue: { [weak self] response in
        guard let self = self else { return }
        
        if response.value.success {
          // Update local userData
          let updatedProfile = UserProfile(
            userId: self.userData.userId,
            email: email,
            name: name
          )
          
          // Save to Valet
          do {
            try ValetService.shared.save(updatedProfile, for: .userProfile)
            print("✅ Updated profile saved to Valet")
            
            
            NotificationCenter.default.post(
                        name: NSNotification.Name("UserProfileUpdated"),
                        object: nil,
                        userInfo: ["profile": updatedProfile]
                    )
            // Update UI
            self.userData = updatedProfile
            let nameLabel = self.fullNameField.viewWithTag(101) as? UILabel
            let phoneLabel = self.phoneField.viewWithTag(101) as? UILabel
            let emailLabel = self.emailField.viewWithTag(101) as? UILabel
            
            nameLabel?.text = name
            phoneLabel?.text = phone
            emailLabel?.text = email
            
            self.showMessage(
              title: "Success",
              body: response.value.message,
              theme: .success
            )
            
            // Reset editing state
            self.isEditingProfile = false
            self.navigationItem.rightBarButtonItem?.title = "Edit"
            self.updateUIForEditingState()
            
            // Post notification for profile update
            NotificationCenter.default.post(
              name: NSNotification.Name("UserProfileUpdated"),
              object: nil,
              userInfo: ["profile": updatedProfile]
            )
            
          } catch {
            self.showMessage(
              title: "Error",
              body: "Failed to save profile locally",
              theme: .error
            )
            self.isEditingProfile = true
            self.navigationItem.rightBarButtonItem?.title = "Save"
            self.updateUIForEditingState()
          }
        } else {
          self.showMessage(
            title: "Error",
            body: response.value.message,
            theme: .error
          )
          self.isEditingProfile = true
          self.navigationItem.rightBarButtonItem?.title = "Save"
          self.updateUIForEditingState()
        }
      }
      .store(in: &cancellables)
  }
  
  private func isValidEmail(_ email: String) -> Bool {
    // Simple email validation
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.\\w{2,}"
    let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailPred.evaluate(with: email)
  }
  
  private func isValidPhone(_ phone: String) -> Bool {
    // Simple phone validation (digits only, 10-15 characters)
    let phoneRegEx = "^[0-9]{10,15}$"
    let phonePred = NSPredicate(format: "SELF MATCHES %@", phoneRegEx)
    return phonePred.evaluate(with: phone)
  }
  
  // MARK: - Keyboard Handling
  private func addKeyboardObservers() {
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
  private func removeKeyboardObservers() {
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc private func keyboardWillShow(notification: NSNotification) {
    // Adjust view or scroll view content inset if needed
  }
  
  @objc private func keyboardWillHide(notification: NSNotification) {
    // Reset view adjustments
  }
  
  // MARK: - Actions
  @objc private func editButtonTapped() {
    isEditingProfile.toggle()
    navigationItem.rightBarButtonItem?.title = isEditingProfile ? "Save" : "Edit"
    updateUIForEditingState()
    
    if !isEditingProfile {
      saveProfileChanges()
    } else {
      // Bring up the keyboard for the first text field
      let nameField = fullNameField.viewWithTag(100) as? UITextField
      nameField?.becomeFirstResponder()
    }
  }
}

// MARK: - UITextFieldDelegate
extension EditProfileViewController: UITextFieldDelegate {
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    // Implement any input validation if needed
    return true
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    // Move to next text field or dismiss keyboard
    if textField == fullNameField.viewWithTag(100) as? UITextField {
      let nextField = phoneField.viewWithTag(100) as? UITextField
      nextField?.becomeFirstResponder()
    } else if textField == phoneField.viewWithTag(100) as? UITextField {
      let nextField = emailField.viewWithTag(100) as? UITextField
      nextField?.becomeFirstResponder()
    } else {
      textField.resignFirstResponder()
    }
    return true
  }
}
