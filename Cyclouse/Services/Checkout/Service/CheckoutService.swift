//
//  CheckoutService.swift
//  Cyclouse
//
//  Created by yoga arie on 29/10/24.
//

import Foundation
import Combine

struct CheckoutService {
  let repository: CheckoutRepository
  
  init(repository: CheckoutRepository = CheckoutNetworkRepository()) {
    self.repository = repository
  }
  
  func checkout(checkout: CheckoutCart) -> AnyPublisher<APIResponse<CheckoutResponse>, Error> {
    return repository.checkout(cart: checkout).eraseToAnyPublisher()
    
  }
}
