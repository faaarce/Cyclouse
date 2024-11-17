//
//  MessageAlert.swift
//  Cyclouse
//
//  Created by yoga arie on 14/11/24.
//

import Foundation
import SwiftMessages
import UIKit
import SnapKit
@MainActor
final class MessageAlert {
  static func show(title: String,
                   message: String,
                   theme: Theme = .warning,
                   duration: SwiftMessages.Duration = .seconds(seconds: 3),
                   backgroundColor: UIColor? = nil,
                   foregroundColor: UIColor? = nil,
                   presentationStyle: SwiftMessages.PresentationStyle = .center) {
    let view = MessageView.viewFromNib(layout: .cardView)
    
    // Configure base theme without affecting background
    view.configureTheme(theme)
    view.configureDropShadow()
    
    // Configure content
    view.configureContent(title: title, body: message)
    view.iconImageView?.isHidden = true  // Hide icon
    
    // Configure background
    (view.backgroundView as? CornerRoundingView)?.backgroundColor = backgroundColor ?? ThemeColor.cardFillColor
    view.backgroundColor = .clear // Clear the main view background
    
    // Configure text colors
    view.titleLabel?.textColor = foregroundColor ?? .white
    view.bodyLabel?.textColor = foregroundColor?.withAlphaComponent(0.7) ?? ThemeColor.labelColorSecondary
    
    // Configure fonts
    view.titleLabel?.font = ThemeFont.semibold(ofSize: 16)
    view.bodyLabel?.font = ThemeFont.medium(ofSize: 14)
    
    // Add button if needed
    view.button?.setTitle(NSLocalizedString("OK", comment: ""), for: .normal)
    view.buttonTapHandler = { _ in
      Task { @MainActor in
        SwiftMessages.hide()
      }
    }
    
    // Configure layout
    view.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    (view.backgroundView as? CornerRoundingView)?.cornerRadius = 12
    
    
    // Show message
    var config = SwiftMessages.Config()
    config.presentationStyle = presentationStyle
    config.presentationContext = .window(windowLevel: .alert)
    config.dimMode = .blur(style: .dark, alpha: 0.9, interactive: true)
    config.interactiveHide = true
    config.duration = duration
    
    
    SwiftMessages.show(config: config, view: view)
  }
  
  
  static func showError(title: String = NSLocalizedString("Error", comment: ""),
                        message: String, duration: SwiftMessages.Duration = .seconds(seconds: 3)) {
    show(
      title: title,
      message: message,
      theme: .error,
      duration: duration,
      presentationStyle: .top
    )
  }
  
  static func showSuccess(title: String = NSLocalizedString("Success", comment: ""),
                             message: String,
                             duration: SwiftMessages.Duration = .seconds(seconds: 3),
                             backgroundColor: UIColor? = nil,
                             foregroundColor: UIColor? = nil) {
         show(
             title: title,
             message: message,
             theme: .success,
             duration: duration,
             backgroundColor: ThemeColor.cardFillColor,
             foregroundColor: foregroundColor,
             presentationStyle: .top
         )
     }
     
  
  static func showInfo(title: String = NSLocalizedString("Info", comment: ""),
                           message: String,
                           duration: SwiftMessages.Duration = .seconds(seconds: 3)) {
          show(
              title: title,
              message: message,
              theme: .info,
              duration: duration
          )
      }
  
  // MARK: - Special Alert Types
  static func showConfirmation(title: String,
                               message: String,
                               confirmTitle: String = NSLocalizedString("Confirm", comment: ""),
                               cancelTitle: String = NSLocalizedString("Cancel", comment: ""),
                               onConfirm: @escaping () -> Void) {
    let view = MessageView.viewFromNib(layout: .cardView)
    
    
    
    // Configure background
    view.backgroundColor = .clear
    (view.backgroundView as? CornerRoundingView)?.cornerRadius = 12
    (view.backgroundView as? CornerRoundingView)?.backgroundColor = ThemeColor.cardFillColor
    
    // Configure content
    view.configureContent(title: title, body: message)
    view.iconImageView?.isHidden = true
    view.iconLabel?.isHidden = true
    
    view.titleLabel?.textColor = ThemeColor.primary
    view.bodyLabel?.textColor = ThemeColor.labelColorSecondary
    view.titleLabel?.font = ThemeFont.bold(ofSize: 18)
    view.bodyLabel?.font = ThemeFont.medium(ofSize: 14)
    view.titleLabel?.textAlignment = .center
    view.bodyLabel?.textAlignment = .center
    
    // Initialize with zero alpha
    view.alpha = 0
    
    // Create main content stack view
    let contentStack = UIStackView()
    contentStack.axis = .vertical
    contentStack.spacing = 24
    contentStack.alignment = .fill
    view.addSubview(contentStack)
    
    // Create button container
    let buttonContainer = UIStackView()
    buttonContainer.axis = .horizontal
    buttonContainer.spacing = 16
    buttonContainer.distribution = .fillEqually
    
    // Configure cancel button
    let cancelButton = UIButton(type: .system)
    cancelButton.setTitle(cancelTitle, for: .normal)
    cancelButton.setTitleColor(.white, for: .normal)
    cancelButton.titleLabel?.font = ThemeFont.semibold(ofSize: 16)
    cancelButton.backgroundColor = ThemeColor.cardFillColor
    cancelButton.layer.cornerRadius = 12
    cancelButton.layer.borderWidth = 1
    cancelButton.layer.borderColor = ThemeColor.primary.cgColor
    cancelButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    cancelButton.addTarget(self, action: #selector(dismissMessage), for: .touchUpInside)
    
    // Add button press animation
    addButtonAnimation(to: cancelButton)
    
    // Configure confirm button
    let confirmButton = UIButton(type: .system)
    confirmButton.setTitle(confirmTitle, for: .normal)
    confirmButton.setTitleColor(.black, for: .normal)
    confirmButton.titleLabel?.font = ThemeFont.bold(ofSize: 16)
    confirmButton.backgroundColor = ThemeColor.primary
    confirmButton.layer.cornerRadius = 12
    confirmButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    confirmButton.addTarget(self, action: #selector(confirmButtonTapped(_:)), for: .touchUpInside)
    
    // Add button press animation
    addButtonAnimation(to: confirmButton)
    
    // Store the completion handler
    objc_setAssociatedObject(confirmButton,
                             UnsafeRawPointer(bitPattern: 1)!,
                             onConfirm,
                             .OBJC_ASSOCIATION_RETAIN)
    
    // Add buttons to container
    buttonContainer.addArrangedSubview(cancelButton)
    buttonContainer.addArrangedSubview(confirmButton)
    
    // Add everything to the content stack
    if let titleLabel = view.titleLabel {
      contentStack.addArrangedSubview(titleLabel)
    }
    if let bodyLabel = view.bodyLabel {
      contentStack.addArrangedSubview(bodyLabel)
    }
    contentStack.addArrangedSubview(buttonContainer)
    
    // Layout content stack
    contentStack.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      contentStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
      contentStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
      contentStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
      contentStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24)
    ])
    
    // Hide default button
    view.button?.isHidden = true
    
    // Add subtle shadow to the card
    view.layer.shadowColor = UIColor.black.cgColor
    view.layer.shadowOffset = CGSize(width: 0, height: 4)
    view.layer.shadowRadius = 12
    view.layer.shadowOpacity = 0.1
    
    var config = SwiftMessages.Config()
    config.presentationStyle = .center
    config.presentationContext = .window(windowLevel: .alert)
    config.duration = .forever
    config.dimMode = .blur(style: .dark, alpha: 0.9, interactive: false)
    config.interactiveHide = false
    
    
    
    
    
    SwiftMessages.show(config: config, view: view)
  }
  
  // Helper method to add button press animation
  private static func addButtonAnimation(to button: UIButton) {
    button.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
    button.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside])
  }
  
  @objc private static func buttonTouchDown(_ sender: UIButton) {
    UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
      sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
    })
  }
  
  @objc private static func buttonTouchUp(_ sender: UIButton) {
    UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
      sender.transform = .identity
    })
  }
  // MARK: - Loading Alert
  static func showLoading(message: String = NSLocalizedString("Loading...", comment: "")) {
    let view = MessageView.viewFromNib(layout: .cardView)
    view.configureTheme(.info)
    view.configureDropShadow()
    
    // Add activity indicator
    let activity = UIActivityIndicatorView(style: .medium)
    activity.startAnimating()
    
    view.configureContent(title: "", body: message)
    view.addSubview(activity)
    
    // Layout activity indicator
    activity.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      activity.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      activity.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
    
    var config = SwiftMessages.Config()
    config.presentationStyle = .center
    config.duration = .forever
    config.dimMode = .gray(interactive: false)
    config.interactiveHide = false
    
    SwiftMessages.show(config: config, view: view)
  }
  
  static func hideLoading() {
    SwiftMessages.hide()
  }
  
  // MARK: - Helper Methods
  @objc private static func dismissMessage() {
    Task { @MainActor in
      SwiftMessages.hide()
    }
  }
  
  @objc private static func confirmButtonTapped(_ sender: UIButton) {
    Task { @MainActor in
      SwiftMessages.hide()
      if let onConfirm = objc_getAssociatedObject(sender, UnsafeRawPointer(bitPattern: 1)!) as? () -> Void {
        onConfirm()
      }
    }
  }
}
