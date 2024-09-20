//
//  Username.swift
//  FoodApp
//
//  Created by Phincon on 16/07/24.
//

import Foundation
  
struct Username: Validateable {
  var value: String
  
  init(_ username: String) throws {
    if let error = Username.validate(username) {
      throw error
    }
    value = username
  }
  
  static func validate(_ value: String) -> ValidationError? {
    let minChar = 6
    
    if minChar > value.count {
      return ValidationError(message: "Username must be at least \(minChar) characters long")
    }
    return nil
  }
  
}

extension Username: ExpressibleByStringLiteral {
  init(stringLiteral value: StringLiteralType) {
    self.value = value
  }
}
