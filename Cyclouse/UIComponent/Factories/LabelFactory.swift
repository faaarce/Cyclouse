//
//  LabelFactory.swift
//  Cyclouse
//
//  Created by yoga arie on 06/09/24.
//

import UIKit

struct LabelFactory {
  static func build(
    text: String?,
    font: UIFont,
    backgroundColor: UIColor = .clear,
    textColor: UIColor = .white,
    textAlignment: NSTextAlignment = .center) -> UILabel {
      let label = UILabel()
      label.text = text
      label.font = font
      label.numberOfLines = 0
      label.backgroundColor = backgroundColor
      label.textColor = textColor
      label.textAlignment = textAlignment
      return label
    }
}
