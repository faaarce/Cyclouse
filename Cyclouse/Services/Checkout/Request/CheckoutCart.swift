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
    var paymentMethod: PaymentMethod
}


struct ShippingAddress: Codable {
    var street: String
    var city: String
    var state: String
    var zipCode: String
    var country: String
}

struct PaymentMethod: Codable {
    var type: String
    var bank: String
}
