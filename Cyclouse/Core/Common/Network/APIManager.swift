//
//  APIManager.swift
//  exercise4
//
//  Created by Phincon on 15/07/24.
//

import Combine
import Alamofire
import Valet
import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case networkError(String)
    case decodingError(String)
    case serverError(String)
    case unknownError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let message):
            return "Network error: \(message)"
        case .decodingError(let message):
            return "Decoding error: \(message)"
        case .serverError(let message):
            return "Server error: \(message)"
        case .unknownError(let message):
            return "Unknown error: \(message)"
        }
    }
}

enum APIManagerError: Error {
    case noValue
    case alamofire(AFError)
}

class APIManager: APIService {
  func request<T: Responseable>(_ api: any API, of: T.Type, includeHeaders: Bool = false) -> AnyPublisher<APIResponse<T>, Error> {
         // Choose encoder based on jsonEncoder flag
         let encoding: ParameterEncoding = api.jsonEncoder ?
             JSONEncoding.default : URLEncoding.default
         
         return AF.request(
             api.url,
             method: api.method,
             parameters: api.params,
             encoding: encoding,  // Use the appropriate encoding
             headers: api.headers
         )
         .publishDecodable(type: T.self)
         .tryMap { response -> APIResponse<T> in
             if let statusCode = response.response?.statusCode, statusCode >= 400 {
                 throw self.handleHTTPError(statusCode: statusCode, data: response.data)
             }
             
             switch response.result {
             case .success(let value):
                 if value.success {
                     return APIResponse<T>(value: value, httpResponse: response.response)
                 } else {
                     throw APIError.serverError(value.message)
                 }
             case .failure(let error):
                 throw self.handleAlamofireError(error)
             }
         }
         .mapError { error -> Error in
             if let error = error as? APIError {
                 return error
             }
             return APIError.unknownError(error.localizedDescription)
         }
         .eraseToAnyPublisher()
     }
  
  private func handleHTTPError(statusCode: Int, data: Data?) -> APIError {
       if let data = data,
          let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
           return .serverError(errorResponse.message)
       }
       return .serverError("HTTP Error: \(statusCode)")
   }
   
   private func handleAlamofireError(_ error: AFError) -> APIError {
       switch error {
       case .invalidURL(let url):
           return .invalidURL
       case .responseValidationFailed(let reason):
           return .serverError("Validation failed: \(reason)")
       case .responseSerializationFailed(let reason):
           return .decodingError("Serialization failed: \(reason)")
       case .sessionTaskFailed(let error):
           if let urlError = error as? URLError {
               return .networkError(urlError.localizedDescription)
           }
           return .networkError(error.localizedDescription)
       default:
           return .unknownError(error.localizedDescription)
       }
   }
   
    
    func request<T: Responseable>(_ api: any API, includeHeaders: Bool = false) -> AnyPublisher<APIResponse<T>, Error> {
        request(api, of: T.self, includeHeaders: includeHeaders)
    }
}

struct ErrorResponse: Codable {
    let message: String
}
