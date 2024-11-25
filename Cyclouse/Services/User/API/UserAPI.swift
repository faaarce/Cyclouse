//
//  UserAPI.swift
//  Cyclouse
//
//  Created by yoga arie on 25/11/24.
//

import Foundation
import Alamofire

enum UserAPI: API {
  case editProfile(userId: String, name: String, email: String, phone: String)
  
  private var baseURL: String {
    Constants.baseURL
  }
  
  var url: URLConvertible {
    switch self {
    case .editProfile(let userId, _, _, _):
      let url = "\(baseURL)/user/\(userId)/profile"
      return url
    }
  }
  
  var method: HTTPMethod {
    switch self {
    case .editProfile:
      return .put
    }
  }
  
  var params: Parameters? {
    switch self {
    case .editProfile(_, let name, let email, let phone):
      return [
        "name": name,
        "phone": phone,
        "email": email
      ]
      
    }
  }
  
  var headers: HTTPHeaders? {
    if let token = TokenManager.shared.getToken() {
      let headers = ["Authorization": token]
              
      return ["Authorization" : token]
    } else {
  
      return nil
    }
  }
}
