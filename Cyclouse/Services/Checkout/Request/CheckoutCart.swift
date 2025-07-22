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
  var shippingMethod: ShippingMethod
}



struct PaymentMethod: Codable {
    var type: String
    var bank: String
}

struct ShippingMethod: Codable {
  var type: String
}
