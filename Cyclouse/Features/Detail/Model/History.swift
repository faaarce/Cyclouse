//
//  History.swift
//  Cyclouse
//
//  Created by yoga arie on 10/10/24.
//

import Foundation
import SwiftData

@Model
final class History {
  @Attribute(.unique) let id: String
  let name: String
  let price: Int
  let brand: String
  let images: [String]
  let descriptions: String
  let time: Double
  
  init(name: String, price: Int, brand: String, images: [String], descriptions: String) {
    self.id = UUID().uuidString
    self.name = name
    self.price = price
    self.brand = brand
    self.images = images
    self.descriptions = descriptions
    self.time = Date().timeIntervalSince1970
  }
}
