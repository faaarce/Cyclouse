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

//// Order Item Model
//struct OrderItem: Codable {
//    let name: String
//    let quantity: Int
//    let productId: String
//    let price: Int
//}
//
//// Payment Method Model
//struct PaymentMethod: Codable {
//    let bank: String
//    let type: String
//}
//
//// Payment Details Model
//struct PaymentDetails: Codable {
//    let virtualAccountNumber: String
//    let amount: Int
//    let expiryDate: String
//    let bank: String
//}
