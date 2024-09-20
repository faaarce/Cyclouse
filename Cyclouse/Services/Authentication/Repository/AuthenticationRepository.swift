//
//  AuthenticationRepository.swift
//  exercise4
//
//  Created by Phincon on 15/07/24.
//

import Foundation
import Combine

protocol AuthenticationRepository {
    func signIn(username: String, password: String) -> AnyPublisher<SignInResponse, Error>
}
