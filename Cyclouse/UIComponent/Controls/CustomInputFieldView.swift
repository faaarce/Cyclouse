//
//  CustomInputFieldView.swift
//  Cyclouse
//
//  Created by yoga arie on 07/09/24.
//
import UIKit
import SnapKit
import PhoneNumberKit

class CustomInputFieldView: UIView {
  
  let label: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
    label.textColor = .white
    label.textAlignment = .left
    return label
  }()
  
  let textField: PaddedTextField = {
    let textField = PaddedTextField()
    textField.textColor = .white
    textField.layer.cornerRadius = 4
    textField.backgroundColor = ThemeColor.cardFillColor
    textField.textPadding = UIEdgeInsets(top: 6, left: 5, bottom: 6, right: 5)
    return textField
  }()
  
  private lazy var toggleButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
    button.tintColor = .white
    button.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
    return button
  }()
  
  private var isPassword: Bool = false
  
  init(labelText: String, placeholder: String, isPassword: Bool = false) {
    super.init(frame: .zero)
    self.isPassword = isPassword
    setup(labelText: labelText, placeholder: placeholder)
    configureKeyboard(labelText: labelText)
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup(labelText: "", placeholder: "")
  }
  
  
  private func configureKeyboard(labelText: String) {
      // Configure keyboard toolbar
      textField.configureKeyboard(placeholder: labelText)
      
      // Set input accessory view position
      textField.inputAccessoryView?.backgroundColor = ThemeColor.cardFillColor
      
      // Handle return key
      textField.addTarget(self, action: #selector(textFieldDidReturn), for: .editingDidEndOnExit)
  }
  
  @objc private func textFieldDidReturn() {
         // Find next responder
         textField.findNextResponder()
     }
  
  private func setup(labelText: String, placeholder: String) {
    label.text = labelText
    textField.attributedPlaceholder = NSAttributedString(
      string: placeholder,
      attributes: [
        NSAttributedString.Key.foregroundColor: UIColor(hex: "9E9E9E"),
        NSAttributedString.Key.font : ThemeFont.medium(ofSize: 14)
      ]
    )
    
    if isPassword {
      textField.isSecureTextEntry = true
      textField.rightView = toggleButton
      textField.rightViewMode = .always
      
      updateToggleButtonConfiguration()
      
    }
    
    let stackView = UIStackView(arrangedSubviews: [label, textField])
    stackView.axis = .vertical
    stackView.spacing = 2
    stackView.distribution = .fillEqually
    stackView.alignment = .fill
    addSubview(stackView)
    stackView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    if isPassword {
      toggleButton.snp.makeConstraints {
        $0.centerY.equalTo(textField)
        $0.right.equalTo(textField).offset(-2)
        $0.width.height.equalTo(10)
      }
    }
  }
  
  private func updateToggleButtonConfiguration() {
    var config = UIButton.Configuration.plain()
    config.image = UIImage(systemName: textField.isSecureTextEntry ? "eye.slash" : "eye")
    config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 15, weight: .regular)
    config.baseForegroundColor = .white
    
    // Adjust content insets instead of image insets
    config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10)
    
    toggleButton.configuration = config
  }
  
  
  @objc private func togglePasswordVisibility() {
    textField.isSecureTextEntry.toggle()
    let imageName = textField.isSecureTextEntry ? "eye.slash" : "eye"
    toggleButton.setImage(UIImage(systemName: imageName), for: .normal)
  }
}

import UIKit
import SnapKit
import PhoneNumberKit

class CustomPhoneInputFieldView: CustomInputFieldView {
    
  private let phoneNumberKit = PhoneNumberUtility()
    private lazy var phoneTextField: PhoneNumberTextField = {
      let textField = PhoneNumberTextField(utility: phoneNumberKit)
        textField.withPrefix = true
        textField.withFlag = true
        textField.withExamplePlaceholder = true
        textField.withDefaultPickerUI = true
        textField.textColor = .white
        textField.backgroundColor = ThemeColor.cardFillColor
        textField.layer.cornerRadius = 4
      textField.flagButton.backgroundColor = .clear
      textField.flagButton.tintColor = .white
        return textField
    }()
    
    init(labelText: String) {
        super.init(labelText: labelText, placeholder: "Enter phone number")
        setupPhoneTextField()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupPhoneTextField()
    }
    
    private func setupPhoneTextField() {
        // Remove the default textField from superview
        textField.removeFromSuperview()
        
        // Configure placeholder
        phoneTextField.attributedPlaceholder = NSAttributedString(
            string: "Enter phone number",
            attributes: [
                NSAttributedString.Key.foregroundColor: UIColor(hex: "9E9E9E"),
                NSAttributedString.Key.font: ThemeFont.medium(ofSize: 14)
            ]
        )
        
        // Add phoneTextField to the stack view
        if let stackView = label.superview as? UIStackView {
            stackView.addArrangedSubview(phoneTextField)
        }
        
        // Set constraints
        phoneTextField.snp.makeConstraints { make in
            make.height.equalTo(42)
        }
        
        // Style the picker
        configureCountryPicker()
    }
    
    private func configureCountryPicker() {
        let options = CountryCodePickerOptions(
            backgroundColor: ThemeColor.background ?? .black,
            separatorColor: ThemeColor.cardFillColor ?? .darkGray,
            textLabelColor: .white,
            textLabelFont: ThemeFont.medium(ofSize: 14),
            detailTextLabelColor: UIColor(hex: "9E9E9E"),
            detailTextLabelFont: ThemeFont.medium(ofSize: 14),
            tintColor: .white,
            cellBackgroundColor: ThemeColor.cardFillColor ?? .darkGray,
            cellBackgroundColorSelection: ThemeColor.primary ?? .blue
        )
        
        phoneTextField.withDefaultPickerUIOptions = options
        
        // Configure the flag button if needed

          phoneTextField.flagButton.backgroundColor = .clear
          phoneTextField.flagButton.tintColor = .white
        
    }
    
    // Expose the phoneTextField
    var getPhoneTextField: PhoneNumberTextField {
        return phoneTextField
    }
    
    // Convenience method to get formatted phone number
    func getFormattedPhoneNumber() -> String? {
        do {
            let phoneNumber = try phoneNumberKit.parse(phoneTextField.text ?? "")
            return phoneNumberKit.format(phoneNumber, toType: .e164)
        } catch {
            return nil
        }
    }
    
    // Validate phone number
    func isValidPhoneNumber() -> Bool {
        return ((try? phoneNumberKit.parse(phoneTextField.text ?? "")) != nil)
    }
}

// Extension to make the phone field match your theme
extension CustomPhoneInputFieldView {
    func applyTheme() {
        phoneTextField.tintColor = .white
        phoneTextField.textColor = .white
        phoneTextField.backgroundColor = ThemeColor.cardFillColor
        

          phoneTextField.flagButton.backgroundColor = .clear
          phoneTextField.flagButton.tintColor = .white
        
    }
}

extension UITextField {
    func findNextResponder() {
        guard let nextField = self.superview?.viewWithTag(self.tag + 1) as? UITextField else {
            self.resignFirstResponder()
            return
        }
        nextField.becomeFirstResponder()
    }
}
