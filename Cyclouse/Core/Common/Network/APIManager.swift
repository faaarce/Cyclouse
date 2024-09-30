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
    
    func request<T: Responseable>(_ api: any API, of: T.Type) -> AnyPublisher<T, Error> {
        AF.request(api.url, method: api.method, parameters: api.params)
            .publishDecodable(type: T.self)
            .tryMap { response -> T in
                switch response.result {
                case .success(let value):
                    if value.success {
                        return value
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
    
    func request<T: Responseable>(_ api: any API) -> AnyPublisher<T, Error> {
        request(api, of: T.self)
    }
}


