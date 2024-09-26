//
//  BikeNetworkRepository.swift
//  Cyclouse
//
//  Created by yoga arie on 26/09/24.
//

import Foundation
import Combine

class BikeNetworkRepository: BikeRepository {
  let apiService: APIService
  
  init(apiService: APIService = APIManager()) {
    self.apiService = apiService
  }
  
  func getBikes() -> AnyPublisher<BikeResponse, Error> {
    apiService.request(BikeAPI.getBikes)
  }
}
