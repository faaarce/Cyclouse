//
//  UserNetworkRepository.swift
//  Cyclouse
//
//  Created by yoga arie on 25/11/24.
//

import Foundation
import Combine

class UserNetworkRepository: UserRepository {
 
  let apiService: APIService
  
  init(apiService: APIService = APIManager()) {
    self.apiService = apiService
  }
  
  func editProfile(userId: String, name: String, phone: String, email: String) -> AnyPublisher<APIResponse<EditProfileResponse>, any Error> {
    apiService.request(UserAPI.editProfile(userId: userId, name: name, email: email, phone: phone), includeHeaders: true)
  }
  
  
}
