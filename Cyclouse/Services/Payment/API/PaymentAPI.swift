//
//  PaymentAPI.swift
//  Cyclouse
//
//  Created by yoga arie on 12/11/24.
//
import Alamofire
import Foundation

enum PaymentAPI: API {
  case pay(orderId: String, status: String)
  
  private var baseURL: String {
    Constants.baseURL
  }
  //http://localhost:8080/orders/698CE6B6-955D-4D44-A9EF-A265B14E881A/confirm
  var url: URLConvertible {
    switch self {
    case .pay(let orderId, _):
      let url = "\(baseURL)/orders/\(orderId)/confirm"
      return url
    }
  }
  
  var method: HTTPMethod {
    switch self {
    case .pay:
      return .post
    }
  }
  
  var params: Parameters? {
    switch self {
    case .pay(_ , let status):
      return ["status": status]
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
