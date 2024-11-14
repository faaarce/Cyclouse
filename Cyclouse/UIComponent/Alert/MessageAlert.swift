//
//  MessageAlert.swift
//  Cyclouse
//
//  Created by yoga arie on 14/11/24.
//

import Foundation
import SwiftMessages
import UIKit

@MainActor
final class MessageAlert {
    static func show(title: String,
                    message: String,
                    theme: Theme = .warning,
                    duration: SwiftMessages.Duration = .seconds(seconds: 3)) {
        let view = MessageView.viewFromNib(layout: .cardView)
        view.configureTheme(theme)
        view.configureDropShadow()
        
        // Configure content
        view.configureContent(
            title: title,
            body: message,
            iconImage: theme.iconImage ?? UIImage(systemName: "house.fill")!
        )
        
        // Add button if needed
        view.button?.setTitle(NSLocalizedString("OK", comment: ""), for: .normal)
      view.buttonTapHandler = { _ in
          Task { @MainActor in
              SwiftMessages.hide()
          }
      }
        // Configure layout
        view.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        (view.backgroundView as? CornerRoundingView)?.cornerRadius = 10
        
        // Show message
        var config = SwiftMessages.Config()
        config.presentationStyle = .center
        config.presentationContext = .window(windowLevel: .alert)
        config.dimMode = .gray(interactive: true)
        config.interactiveHide = true
        config.duration = duration
        
        SwiftMessages.show(config: config, view: view)
    }
  
  static func showError(title: String = NSLocalizedString("Error", comment: ""),
                       message: String) {
      show(title: title, message: message, theme: .error)
  }
}
