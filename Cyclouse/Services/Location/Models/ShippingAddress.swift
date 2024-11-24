//
//  ShippingAddress.swift
//  Cyclouse
//
//  Created by yoga arie on 24/11/24.
//

import Foundation

struct ShippingAddress: Codable {
    var street: String
    var city: String
    var state: String
    var zipCode: String
    var country: String
}
