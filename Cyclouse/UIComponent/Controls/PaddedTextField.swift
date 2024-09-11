//
//  PaddedTextField.swift
//  Cyclouse
//
//  Created by yoga arie on 07/09/24.
//

import UIKit

class PaddedTextField: UITextField {
  // Set padding for the text field
  var textPadding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
  
  override func textRect(forBounds bounds: CGRect) -> CGRect {
    super.textRect(forBounds: bounds.inset(by: textPadding))
  }
  
  override func editingRect(forBounds bounds: CGRect) -> CGRect {
    super.editingRect(forBounds: bounds.inset(by: textPadding))
  }
  
  override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
    super.placeholderRect(forBounds: bounds.inset(by: textPadding))
  }
}
