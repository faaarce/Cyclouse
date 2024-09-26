//
//  Bike.swift
//  Cyclouse
//
//  Created by yoga arie on 26/09/24.
//

import Foundation

struct BikeShopResponse: Codable, Responseable {
  var message: String
  
  var success: Bool
  
    let bikes: BikeCategories
}

struct BikeCategories: Codable {
    let categories: [BikeCategory]
}

struct BikeCategory: Codable {
    let categoryName: String
    let products: [BikeProduct]
}

struct BikeProduct: Codable {
    let name: String
    let description: String
    let images: [String]
    let price: Double
    let brand: String
}

