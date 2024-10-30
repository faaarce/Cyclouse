//
//  CheckoutCart.swift
//  Cyclouse
//
//  Created by yoga arie on 29/10/24.
//

import Foundation

struct CheckoutCart: Codable {
  var items: [CartItem]
    var shippingAddress: ShippingAddress
}

struct CheckoutItem: Codable {
    var productId: String
    var quantity: Int
}

struct ShippingAddress: Codable {
    var street: String
    var city: String
    var state: String
    var zipCode: String
    var country: String
}
