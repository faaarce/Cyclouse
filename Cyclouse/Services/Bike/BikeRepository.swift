//
//  BikeRepository.swift
//  Cyclouse
//
//  Created by yoga arie on 26/09/24.
//
import Combine
import Foundation

protocol BikeRepository{
  func getBikes() -> AnyPublisher<BikeResponse, Error>
}
