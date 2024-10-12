//
//  BikeProduct.swift
//  Cyclouse
//
//  Created by yoga arie on 09/10/24.
//

import Foundation
import SwiftData

@Model
final class BikeProduct {
  @Attribute(.unique) let id: String
  let name: String
  let price: Int
  let brand: String
  let images: [String]
  let descriptions: String
  let time: Double
  @Attribute(.externalStorage) var quantity: Int
  
  init(name: String, price: Int, brand: String, images: [String], descriptions: String, quantity: Int) {
    self.id = UUID().uuidString
    self.name = name
    self.price = price
    self.brand = brand
    self.images = images
    self.descriptions = descriptions
    self.time = Date().timeIntervalSince1970
    self.quantity = quantity
  }
}
