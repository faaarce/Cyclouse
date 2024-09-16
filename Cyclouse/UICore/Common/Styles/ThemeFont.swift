//
//  ThemeFont.swift
//  Cyclouse
//
//  Created by yoga arie on 06/09/24.
//

import UIKit

struct ThemeFont {
  
  static func semibold(ofSize size: CGFloat) -> UIFont {
    return UIFont(name: "PlusJakartaSans-SemiBold", size: size) ?? .systemFont(ofSize: size)
  }
  
  static func regular(ofSize size: CGFloat) -> UIFont {
    return UIFont(name: "PlusJakartaSans-Regular", size: size) ?? .systemFont(ofSize: size)
  }
  
  static func bold(ofSize size: CGFloat) -> UIFont {
    return UIFont(name: "PlusJakartaSans-Bold", size: size) ?? .systemFont(ofSize: size)
  }
  
  static func medium(ofSize size: CGFloat) -> UIFont {
    return UIFont(name: "PlusJakartaSans-Medium", size: size) ?? .systemFont(ofSize: size)
  }
  
  static func light(ofSize size: CGFloat) -> UIFont {
    return UIFont(name: "PlusJakartaSans-Light", size: size) ?? .systemFont(ofSize: size)
  }
  
  static func extraBold(ofSize size: CGFloat) -> UIFont {
    return UIFont(name: "PlusJakartaSans-ExtraBold", size: size) ?? .systemFont(ofSize: size)
  }
}
