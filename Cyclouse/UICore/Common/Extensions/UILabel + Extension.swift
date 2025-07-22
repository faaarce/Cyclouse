//
//  UILabel + Extension.swift
//  Cyclouse
//
//  Created by yoga arie on 16/06/25.
//

import Foundation
import UIKit  

// MARK: - Status Badge Support
extension UILabel {
    
    /// Configures the label as a status badge with predefined styling
    /// - Parameters:
    ///   - status: The status text to display
    ///   - style: The visual style to apply to the badge
    func configureAsStatusBadge(status: String, style: StatusBadgeStyle) {
        // Set the text
        self.text = status
        
        // Apply the style
        self.font = style.font
        self.textColor = style.textColor
        self.backgroundColor = style.backgroundColor
        self.textAlignment = style.textAlignment
        
        // Apply corner radius for pill shape
        self.layer.cornerRadius = style.cornerRadius
        self.layer.masksToBounds = true
        
        // Apply border if specified
        if let borderColor = style.borderColor {
            self.layer.borderColor = borderColor.cgColor
            self.layer.borderWidth = style.borderWidth
        }
    }
    
    /// Adds padding to the label by using attributed string
    /// This is a workaround since UILabel doesn't have built-in padding
    func addTextPadding(left: CGFloat = 16, right: CGFloat = 16) {
        guard let text = self.text else { return }
        
        // Calculate spacing based on font metrics
        let spacing = String(repeating: " ", count: Int(left/4))
        self.text = "\(spacing)\(text)\(spacing)"
    }
}

// MARK: - Status Badge Style Configuration
struct StatusBadgeStyle {
    let font: UIFont
    let textColor: UIColor
    let backgroundColor: UIColor
    let cornerRadius: CGFloat
    let textAlignment: NSTextAlignment
    let borderColor: UIColor?
    let borderWidth: CGFloat
    
    // Predefined styles for common statuses
    static let paid = StatusBadgeStyle(
        font: ThemeFont.medium(ofSize: 12),
        textColor: ThemeColor.cardFillColor,
        backgroundColor: ThemeColor.primary,
        cornerRadius: 12,
        textAlignment: .center,
        borderColor: nil,
        borderWidth: 0
    )
    
    static let pending = StatusBadgeStyle(
        font: ThemeFont.medium(ofSize: 12),
        textColor: .white,
        backgroundColor: UIColor(red: 251/255, green: 146/255, blue: 60/255, alpha: 1.0),
        cornerRadius: 12,
        textAlignment: .center,
        borderColor: nil,
        borderWidth: 0
    )
    
    static let cancelled = StatusBadgeStyle(
        font: ThemeFont.medium(ofSize: 12),
        textColor: .white,
        backgroundColor: UIColor(red: 239/255, green: 68/255, blue: 68/255, alpha: 1.0),
        cornerRadius: 12,
        textAlignment: .center,
        borderColor: nil,
        borderWidth: 0
    )
}

// MARK: - Enhanced Label Creation
extension UILabel {
    /// Creates a label configured as a status badge
    /// This is useful when you want to create and configure in one step
    static func createStatusBadge(status: String, style: StatusBadgeStyle) -> UILabel {
        let label = UILabel()
        label.configureAsStatusBadge(status: status, style: style)
        label.addTextPadding()
        return label
    }
}
