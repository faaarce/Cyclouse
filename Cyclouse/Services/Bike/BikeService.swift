//
//  BikeService.swift
//  Cyclouse
//
//  Created by yoga arie on 26/09/24.
//
import Combine
import Foundation

struct BikeService {
  let repository: BikeRepository
  
  init(repository: BikeRepository = BikeNetworkRepository()) {
    self.repository = repository
  }
  
  func getBikes() -> AnyPublisher<BikeResponse, Error> {
    return repository.getBikes().eraseToAnyPublisher()
  }
}
