//
//  CheckoutAPI.swift
//  Cyclouse
//
//  Created by yoga arie on 29/10/24.
//

import Foundation
import Alamofire

enum CheckoutAPI: API  {
  case checkout(cart: CheckoutCart)
  
  private var baseURL: String {
    "http://localhost:8080"
  }
  
  var url: URLConvertible {
    switch self {
    case .checkout:
    let url = "\(baseURL)/checkout"
      print("🌐 API URL: \(url)")
      return url
    }
  }
  
  var method: HTTPMethod {
    switch self {
    case .checkout:
      return .post
    }
  }
  
  var params: Parameters? {
    switch self {
    case .checkout(let cart):
      if let data = try? JSONEncoder().encode(cart),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
               return dict
           }
           return nil    }
  }
  
  var headers: HTTPHeaders? {
    if let token = TokenManager.shared.getToken() {
      let headers = ["Authorization": token]
                print("📋 Request Headers:")
                dump(headers)
      return ["Authorization" : token]
    } else {
      print("⚠️ No Authorization Token Available!")
      return nil
    }
  }
  
  var jsonEncoder: Bool{
   return true
  }
  
}


/*
 [
  "items": cart.items.map { ["productId": $0.productId, "quantity": $0.quantity] },
  "shippingAddress": [
      "street": cart.shippingAddress.street,
      "city": cart.shippingAddress.city,
      "state": cart.shippingAddress.state,
      "zipCode": cart.shippingAddress.zipCode,
      "country": cart.shippingAddress.country
  ]
]
 */
