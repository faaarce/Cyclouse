//
//  HistoryAPI.swift
//  Cyclouse
//
//  Created by faris arie on 12/11/24.
//

import Foundation
import Alamofire

enum HistoryAPI: API {
  case history
  
  private var baseURL: String {
    Constants.baseURL
  }
  
  var url: any URLConvertible {
    let url = "\(baseURL)/orders"
    return url
  }
  
  var method: HTTPMethod {
    return .get
  }
  
  var params: Alamofire.Parameters? {
    return nil
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
}
