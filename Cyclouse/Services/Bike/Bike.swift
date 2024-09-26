//
//  Bike.swift
//  Cyclouse
//
//  Created by yoga arie on 26/09/24.
//

import Foundation

struct Bikes: Codable {
  let id: String
  let model: String
}

struct BikeResponse: Responseable {
  let success: Bool
  let message: String
  let bikes: [Bikes]?
}
