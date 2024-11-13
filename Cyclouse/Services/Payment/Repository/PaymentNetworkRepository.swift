//
//  PaymentNetworkRepositoy.swift
//  Cyclouse
//
//  Created by yoga arie on 12/11/24.
//

import Foundation
import Combine

class PaymentNetworkRepository: PaymentRepository {
  let apiService: APIService
  
  init(apiService: APIService = APIManager()) {
    self.apiService = apiService
  }
  
  func pay(orderId: String, status: String) -> AnyPublisher<APIResponse<PaymentStatusResponse>, any Error> {
    apiService.request(PaymentAPI.pay(orderId: orderId, status: status), includeHeaders: true)
  }
}
