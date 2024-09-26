//
//  BikeAPI.swift
//  Cyclouse
//
//  Created by yoga arie on 26/09/24.
//

import Foundation
import Alamofire
import Combine

enum BikeAPI: API {
  case getBikes
  
  private var baseURL: String {
    "https://localhost:3001"
  }
  
  var url: any URLConvertible {
    switch self {
    case .getBikes:
      return "\(baseURL)/bikes"
    }
  }
  
  var method: Alamofire.HTTPMethod {
    switch self {
    case .getBikes:
      return .get
    }
  }
  
  
  var params: Alamofire.Parameters? {
    switch self {
    case .getBikes:
      return nil
    }
  }
}
