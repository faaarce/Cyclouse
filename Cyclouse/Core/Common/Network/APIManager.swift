//
//  APIManager.swift
//  exercise4
//
//  Created by Phincon on 15/07/24.
//

import Combine
import Alamofire
import Valet

enum APIManagerError: Error {
    case noValue
    case alamofire(AFError)
}

class APIManager: APIService {
    func request<T: Responseable>(_ api: any API, of: T.Type, includeHeaders: Bool = false) -> AnyPublisher<APIResponse<T>, Error> {
        AF.request(api.url, method: api.method, parameters: api.params)
            .publishDecodable(type: T.self)
            .tryMap { response -> APIResponse<T> in
                switch response.result {
                case .success(let value):
                    if value.success {
                        let headers = includeHeaders ? response.response?.headers.dictionary : nil
                      return APIResponse<T>(value: value, httpResponse: response.response) //Generic parameter 'T' could not be inferred
                    } else {
                        throw ServerMessageError(message: value.message)
                    }
                case .failure(let error):
                    throw APIManagerError.alamofire(error)
                }
            }
            .mapError { error -> Error in
                if let error = error as? AFError {
                    return APIManagerError.alamofire(error)
                }
                return error
            }
            .eraseToAnyPublisher()
    }
    
    func request<T: Responseable>(_ api: any API, includeHeaders: Bool = false) -> AnyPublisher<APIResponse<T>, Error> {
        request(api, of: T.self, includeHeaders: includeHeaders)
    }
}

