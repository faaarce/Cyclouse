//
//  AuthenticationValidationError.swift
//  FoodApp
//
//  Created by Phincon on 16/07/24.
//

enum AuthenticationValidationError: Error {
  case emailNotValid, passwordNotValid
  
  var message: String {
    switch self {
    case .emailNotValid:
      return "email not valid, please use valid email ex: name@example.com"
    case .passwordNotValid:
      return "password not valid"
    }
  }
  
}
