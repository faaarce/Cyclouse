//
//  BikeV2.swift
//  Cyclouse
//
//  Created by yoga arie on 12/10/24.
//

import Foundation

import SwiftData

@Model
final class BikeV2 {
  @Attribute(.unique) var id: String
  var name: String
  var price: Int
  var brand: String
  var images: [String]
  var descriptions: String
  var time: Double
  var stockQuantity: Int
  var cartQuantity: Int
  
  init(name: String, price: Int, brand: String, images: [String], descriptions: String, stockQuantity: Int, cartQuantity: Int = 1) {
    self.id = UUID().uuidString
    self.name = name
    self.price = price
    self.brand = brand
    self.images = images
    self.descriptions = descriptions
    self.time = Date().timeIntervalSince1970
    self.stockQuantity = stockQuantity
    self.cartQuantity = cartQuantity
  }
}
