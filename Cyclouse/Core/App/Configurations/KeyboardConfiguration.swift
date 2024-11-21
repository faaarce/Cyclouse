//
//  KeyboardConfiguration.swift
//  Cyclouse
//
//  Created by yoga arie on 21/11/24.
//
import UIKit
import IQKeyboardManagerSwift

/// Manages keyboard configuration across the app
struct KeyboardConfiguration {
    
    /// Applies custom configuration to specific text fields
  @MainActor static func configure(_ textField: UITextField, placeholder: String? = nil, returnKeyType: UIReturnKeyType = .next) {
        textField.returnKeyType = returnKeyType
        
        // Set toolbar title if needed
        if let placeholder = placeholder {
          textField.iq.placeholder = placeholder
        }
    }
    
    /// Applies custom configuration to a view controller
    static func configure(_ viewController: UIViewController) {
        // Disable IQKeyboardManager for specific view controller if needed
        // IQKeyboardManager.shared.enableAutoToolbar = false
        // IQKeyboardManager.shared.enable = false
    }
    
    /// Reset to default configuration
  @MainActor static func resetConfiguration() {
        IQKeyboardManager.shared.enableAutoToolbar = true
      IQKeyboardManager.shared.isEnabled = true
    }
}

// MARK: - UITextField Extension for IQKeyboard
extension UITextField {
    /// Configure keyboard settings for this text field
    func configureKeyboard(placeholder: String? = nil, returnKeyType: UIReturnKeyType = .next) {
        KeyboardConfiguration.configure(self, placeholder: placeholder, returnKeyType: returnKeyType)
    }
}
