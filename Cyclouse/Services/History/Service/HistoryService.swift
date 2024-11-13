//
//  HistoryService.swift
//  Cyclouse
//
//  Created by yoga arie on 12/11/24.
//

import Foundation
import Combine

struct HistoryService {
  let repository: HistoryRepository
  
  init(repository: HistoryRepository = HistoryNetworkRepository()) {
    self.repository = repository
  }
  
  func history() -> AnyPublisher<APIResponse<OrderHistoryResponse>, Error> {
    return repository.history().eraseToAnyPublisher()
  }
}
