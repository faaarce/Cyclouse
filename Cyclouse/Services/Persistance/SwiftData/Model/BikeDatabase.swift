//
//  BikeDatabase.swift
//  Cyclouse
//
//  Created by yoga arie on 09/11/24.
//

import Foundation
import SwiftData

@Model
final class BikeDatabase {
  @Attribute(.unique) var id: String
  var productId: String
  var name: String
  var price: Int
  var brand: String
  var images: [String]
  var descriptions: String
  var time: Double
  var stockQuantity: Int
  var cartQuantity: Int
  
  init(name: String, price: Int, brand: String, images: [String], descriptions: String, stockQuantity: Int, cartQuantity: Int = 1, productId: String) {
    self.id = UUID().uuidString
    self.name = name
    self.price = price
    self.brand = brand
    self.images = images
    self.descriptions = descriptions
    self.time = Date().timeIntervalSince1970
    self.stockQuantity = stockQuantity
    self.cartQuantity = cartQuantity
    self.productId = productId
  }
}
