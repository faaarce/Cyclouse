//
//  Password.swift
//  FoodApp
//
//  Created by Phincon on 16/07/24.
//

import Foundation

struct Password: Validateable {
  let value: String
  
  init(_ value: String) throws {
    if let error = Password.validate(value) {
      throw error
    }
    self.value = value
  }
  
  static func validate(_ value: String) -> ValidationError? {
    let minChar = 6
    if minChar > value.count {
      return ValidationError(message: "Password must be at least \(minChar) characters long")
    }
    return nil
  }
  
}

extension Password: ExpressibleByStringLiteral {
  init(stringLiteral value: StringLiteralType) {
    self.value = value
  }
}
