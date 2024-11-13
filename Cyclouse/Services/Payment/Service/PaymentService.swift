//
//  PaymentService.swift
//  Cyclouse
//
//  Created by yoga arie on 12/11/24.
//

import Foundation
import Combine

struct PaymentService {
  let repository: PaymentRepository
  
  init(repository: PaymentRepository = PaymentNetworkRepository()) {
    self.repository = repository
  }
  
  func pay(orderId: String, status: String) -> AnyPublisher<APIResponse<PaymentStatusResponse>, Error> {
    return repository.pay(orderId: orderId, status: status)
      .eraseToAnyPublisher()
  }
}
