//
//  HistoryNetworkRepository.swift
//  Cyclouse
//
//  Created by yoga arie on 12/11/24.
//

import Foundation
import Combine

class HistoryNetworkRepository: HistoryRepository {
  let apiService: APIService
  
  init(apiService: APIService = APIManager()) {
    self.apiService = apiService
  }
  
  func history() -> AnyPublisher<APIResponse<OrderHistoryResponse>, any Error> {
    apiService.request(HistoryAPI.history, includeHeaders: true)
  }
}
