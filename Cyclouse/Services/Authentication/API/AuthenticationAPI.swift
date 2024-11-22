//
//  AuthenticationAPI.swift
//  exercise4
//
//  Created by Phincon on 15/07/24.
//

import Alamofire

enum AuthenticationAPI: API {
  case signin(email: String, password: String)
  case signup(name: String, email: String, phone: String, password: String)
  case signout
  
  private var baseURL: String {
    Constants.baseURL
  }
  
  var url: any URLConvertible {
    switch self {
    case .signin:
      return "\(baseURL)/auth/login"
      
    case .signup:
      return "\(baseURL)/auth/register"
      
    case .signout:
      return "\(baseURL)/auth/logout"
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
      
    case .signup(let username, let email, let phone, let password):
      return [
        "name": username,
        "email": email,
        "phone": phone,
        "password": password,
        "confirmPassword": password
      ]
      
    case .signout:
      return nil
    }
  }
  
  var headers: HTTPHeaders? {
    switch self {
    case .signout:
      if let token = TokenManager.shared.getToken() {
        return ["Authorization" : token]
      } else {
        print("No authorization token available")
      }
    default:
      return nil
    }
    return nil
  }
  
}
