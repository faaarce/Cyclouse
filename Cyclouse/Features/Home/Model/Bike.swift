//
//  Bike.swift
//  Cyclouse
//
//  Created by yoga arie on 10/09/24.
//

import Foundation

import SwiftData

@Model
final class Bike {
    @Attribute(.unique) var id: String
    var name: String
    var price: Int
    var brand: String
    var images: [String]
    var descriptions: String
    var time: Double
    var quantity: Int

    init(name: String, price: Int, brand: String, images: [String], descriptions: String, quantity: Int = 0) {
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
