//
//  PaymentRepository.swift
//  Cyclouse
//
//  Created by yoga arie on 12/11/24.
//

import Foundation
import Combine

protocol PaymentRepository {
  func pay(orderId: String, status: String) -> AnyPublisher<APIResponse<PaymentStatusResponse>, Error>
}
