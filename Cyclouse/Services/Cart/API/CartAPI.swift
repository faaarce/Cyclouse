//
//  CartAPI.swift
//  Cyclouse
//
//  Created by yoga arie on 01/10/24.
//

import Foundation

import Alamofire

enum CartAPI: API {
  case addToCart(productId: String, quantity: Int)
  case getCart
  
  private var baseURL: String {
    AppConfig.current.environment.baseURL
  }
  
  var url: URLConvertible {
    switch self {
    case .addToCart:
      return "\(baseURL)/cart/add"
      
    case .getCart:
      return "\(baseURL)/cart"
    }
  }
  
  var method: HTTPMethod {
    switch self {
    case .addToCart:
      return .post
      
    case .getCart:
      return .get
    }
  }
  
  var params: Parameters? {
    switch self {
    case .addToCart(let productId, let quantity):
      return ["productId": productId, "quantity": quantity]
      
    case .getCart:
      return nil
    }
  }
  
  var headers: HTTPHeaders? {
    if let token = TokenManager.shared.getToken() {
      return ["Authorization" : token]
    } else {
      print("No authorization token available")
      return nil
    }
  }
}

