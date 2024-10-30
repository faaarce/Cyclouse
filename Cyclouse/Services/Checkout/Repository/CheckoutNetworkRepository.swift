//
//  CheckoutNetworkRepository.swift
//  Cyclouse
//
//  Created by yoga arie on 29/10/24.
//

import Foundation
import Combine

class CheckoutNetworkRepository: CheckoutRepository {
  let apiService: APIService
  
  init(apiService: APIService = APIManager()) {
    self.apiService = apiService
  }
  
  func checkout(cart: CheckoutCart) -> AnyPublisher<APIResponse<CheckoutResponse>, any Error> {
    apiService.request(CheckoutAPI.checkout(cart: cart), includeHeaders: true)
   
  }
}
