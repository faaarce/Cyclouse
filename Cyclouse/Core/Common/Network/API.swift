//
//  API.swift
//  exercise4
//
//  Created by Phincon on 15/07/24.
//
import Alamofire

protocol API {
  var url: URLConvertible { get }
  var method: HTTPMethod { get }
  var params: Parameters? { get }
}
