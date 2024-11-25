//
//  UserProfileService.swift
//  Cyclouse
//
//  Created by yoga arie on 25/11/24.
//

import Foundation
import Combine

struct UserProfileService {
  let repository: UserRepository
  
  init(repository: UserRepository = UserNetworkRepository()) {
    self.repository = repository
  }
  
  func editProfile(userId: String, name: String, phone: String, email: String) -> AnyPublisher<APIResponse<EditProfileResponse>, Error> {
    return repository.editProfile(userId: userId, name: name, phone: phone, email: email)
  }
}
