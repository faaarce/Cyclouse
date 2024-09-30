//
//  AuthenticationAPI.swift
//  exercise4
//
//  Created by Phincon on 15/07/24.
//

import Alamofire

enum AuthenticationAPI: API {
  case signin(email: String, password: String)
  case signup(username: String, email: String, password: String)
  
  private var baseURL: String {
    "http://localhost:8080"
  }
  
  var url: any URLConvertible {
    switch self {
    case .signin:
      return "\(baseURL)/auth/login"
    case .signup:
      return "\(baseURL)/auth/signup"
    }
  }
  
  var method: Alamofire.HTTPMethod {
    return .post
  }
  
  var params: Alamofire.Parameters? {
    switch self {
    case .signin(let email, let password):
      return [
        "email": email,
        "password": password
      ]
      
    case .signup(let username, let email, let password):
      return [
        "username": username,
        "email": email,
        "password": password
      ]
      
    }
  }
  
}
