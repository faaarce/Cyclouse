//
//  APIService.swift
//  exercise4
//
//  Created by Phincon on 15/07/24.
//
import Combine

protocol APIService {
    func request<T: Responseable>(_ api: any API, of: T.Type) -> AnyPublisher<T, Error>
    func request<T: Responseable>(_ api: any API) -> AnyPublisher<T, Error>
}
