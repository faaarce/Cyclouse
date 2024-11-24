//
//  OrderHistoryResponse.swift
//  Cyclouse
//
//  Created by yoga arie on 12/11/24.
//

import Foundation

struct OrderHistoryResponse: Responseable {
    let message: String
    let data: [OrderHistory]
    let success: Bool
}

// Order History Model
struct OrderHistory: Codable {
    let orderId: String
    let items: [OrderItem]
    let total: Int
    let createdAt: String
    let shippingAddress: String
    let status: String
    let userId: String
    let paymentMethod: PaymentMethod
    let paymentDetails: PaymentDetails
}


