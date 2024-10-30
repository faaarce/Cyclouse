//
//  CheckoutRepository.swift
//  Cyclouse
//
//  Created by yoga arie on 29/10/24.
//

import Foundation
import Combine

protocol CheckoutRepository {
  func checkout(cart: CheckoutCart) -> AnyPublisher<APIResponse<CheckoutResponse>, Error>
}
