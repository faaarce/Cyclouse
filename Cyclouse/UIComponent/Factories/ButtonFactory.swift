//
//  ButtonFactory.swift
//  Cyclouse
//
//  Created by yoga arie on 07/09/24.
//

import UIKit

struct ButtonFactory {
  static func build(title: String, font: UIFont) -> UIButton {
    let button = UIButton(type: .custom)
    button.backgroundColor = ThemeColor.primary
    button.addCornerRadius(radius: 8.0)
    button.titleLabel?.font = font
    button.setTitle(title, for: .normal)
    button.setTitleColor(ThemeColor.black, for: .normal)
    return button
  }
}
