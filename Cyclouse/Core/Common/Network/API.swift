//
//  API.swift
//  exercise4
//
//  Created by Phincon on 15/07/24.
//
import Alamofire
import Foundation

protocol API {
  var url: URLConvertible { get }
  var method: HTTPMethod { get }
  var params: Parameters? { get }
  var headers: HTTPHeaders? { get }
  var jsonEncoder: Bool { get }
}

extension API {
    var jsonEncoder: Bool {
        return false // Default to false, which will use default encoding
    }
}


struct APIResponse<T: Responseable> {
    let value: T
    let httpResponse: HTTPURLResponse?
}
