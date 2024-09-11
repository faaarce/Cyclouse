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
  
  init(labelText: String, placeholder: String) {
    super.init(frame: .zero)
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
    
    let stackView = UIStackView(arrangedSubviews: [label, textField])
    stackView.axis = .vertical
    stackView.spacing = 2
    stackView.distribution = .fillEqually
    stackView.alignment = .fill
    addSubview(stackView)
    stackView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
}
