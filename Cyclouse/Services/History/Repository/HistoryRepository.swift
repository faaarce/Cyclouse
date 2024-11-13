//
//  HistoryRepository.swift
//  Cyclouse
//
//  Created by yoga arie on 12/11/24.
//

import Foundation
import Combine

protocol HistoryRepository {
  func history() -> AnyPublisher<APIResponse<OrderHistoryResponse>, Error>
}
