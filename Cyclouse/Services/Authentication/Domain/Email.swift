//
//  Email.swift
//  FoodApp
//
//  Created by Phincon on 16/07/24.
//

import Foundation

struct Email: Validateable {
  let value: String
  
  init(_ value: String) throws {
    if let error = Email.validate(value) {
      throw error
    }
    self.value = value
  }
  
  static func validate(_ email: String) -> ValidationError? {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    if !emailPred.evaluate(with: email) {
      return ValidationError(message: "Invalid email address")
    }
    return nil
  }

}
