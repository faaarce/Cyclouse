//
//  Bike.swift
//  Cyclouse
//
//  Created by yoga arie on 26/09/24.
//

import Foundation

// MARK: - BikeDataResponse
struct BikeDataResponse: Codable, Responseable {
  let message: String
  let success: Bool
  let bikes: Bikes
}

// MARK: - Bikes
struct Bikes: Codable {
  let categories: [Category]
}

// MARK: - Category
struct Category: Codable {
  let categoryName: String
  let products: [Product]
}

// MARK: - Product
struct Product: Codable {
  let id: String
  let name: String
  let description: String
  let images: [String]
  let price: Int
  let brand: String
  let quantity: Int
}

// MARK: - Convenience Initializers
extension BikeDataResponse {
  init(data: Data) throws {
    self = try JSONDecoder().decode(BikeDataResponse.self, from: data)
  }
  
  init(_ json: String, using encoding: String.Encoding = .utf8) throws {
    guard let data = json.data(using: encoding) else {
      throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
    }
    try self.init(data: data)
  }
}

// MARK: - Convenience methods
extension BikeDataResponse {
  var allProducts: [Product] {
    return bikes.categories.flatMap { $0.products }
  }
  
  func products(for category: String) -> [Product] {
    return bikes.categories.first { $0.categoryName == category }?.products ?? []
  }
}
