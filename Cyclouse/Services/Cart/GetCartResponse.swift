//
//  GetCartResponse.swift
//  Cyclouse
//
//  Created by yoga arie on 02/10/24.
//

import Foundation

struct GetCartResponse: Responseable {
  let data: CartData
    let success: Bool
    let message: String
}

struct CartData: Codable {
  let items : [CartItem]
}

struct CartItem: Codable {
    let productId: String
    let quantity: Int
}

