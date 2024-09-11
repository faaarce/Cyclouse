//
//  ThemeFont.swift
//  Cyclouse
//
//  Created by yoga arie on 06/09/24.
//

import UIKit

struct ThemeFont {
  
  static func semibold(ofSize size: CGFloat) -> UIFont {
    return UIFont(name: "Manrope-SemiBold", size: size) ?? .systemFont(ofSize: size)
  }  
  
  static func regular(ofSize size: CGFloat) -> UIFont {
    return UIFont(name: "Manrope-Regular", size: size) ?? .systemFont(ofSize: size)
  }
  
  static func bold(ofSize size: CGFloat) -> UIFont {
    return UIFont(name: "Manrope-Bold", size: size) ?? .systemFont(ofSize: size)
  }
  
  static func medium(ofSize size: CGFloat) -> UIFont {
    return UIFont(name: "Manrope-Medium", size: size) ?? .systemFont(ofSize: size)
  }
  
  static func light(ofSize size: CGFloat) -> UIFont {
    return UIFont(name: "Manrope-Light", size: size) ?? .systemFont(ofSize: size)
  } 
  
  static func extraBold(ofSize size: CGFloat) -> UIFont {
    return UIFont(name: "Manrope-ExtraBold", size: size) ?? .systemFont(ofSize: size)
  }
}
