//
//  UserRepository.swift
//  Cyclouse
//
//  Created by yoga arie on 25/11/24.
//

import Foundation
import Combine

protocol UserRepository {
  func editProfile(userId: String, name: String, phone: String, email: String) -> AnyPublisher<APIResponse<EditProfileResponse>, Error>
}
