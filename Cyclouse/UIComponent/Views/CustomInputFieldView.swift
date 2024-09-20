//
//  CustomInputFieldView.swift
//  Cyclouse
//
//  Created by yoga arie on 07/09/24.
//
import UIKit
import SnapKit

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
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup(labelText: "", placeholder: "")
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
