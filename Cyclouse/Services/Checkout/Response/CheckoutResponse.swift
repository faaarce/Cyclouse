//
//  CheckoutResponse.swift
//  Cyclouse
//
//  Created by yoga arie on 29/10/24.
//

import Foundation

struct CheckoutResponse: Responseable {
  var message: String
  
  var success: Bool
  
  let data: CheckoutData
}


struct CheckoutData: Codable {
    let userId: String
    let status: String
    let shippingAddress: String
    let total: Int
    let createdAt: String
    let items: [CartItem]
    let id: String
}

//// MARK: - Checkout Data
//struct CheckoutData: Codable {
//    let items: [OrderItem]
//    let shippingAddress: String
//    let createdAt: String
//    let total: Int
//    let userId: String
//    let id: String
//    let status: OrderStatus
//}
//
//// MARK: - Order Item
//struct OrderItem: Codable {
//    let productId: String
//    let quantity: Int
//}

//// MARK: - Order Status
//enum OrderStatus: String, Codable {
//    case pending
//    case confirmed
//    case processing
//    case shipped
//    case delivered
//    case cancelled
//}
//
//// MARK: - Convenience Extensions
//extension CheckoutData {
//    // Convert string date to Date object
//    var createdDate: Date? {
//        let formatter = ISO8601DateFormatter()
//        return formatter.date(from: createdAt)
//    }
//    
//    // Format total as currency
//    var formattedTotal: String {
//        let numberFormatter = NumberFormatter()
//        numberFormatter.numberStyle = .currency
//        numberFormatter.locale = Locale(identifier: "id_ID") // Indonesian Rupiah
//        
//        let amount = Double(total) / 100.0 // Assuming the total is in cents
//        return numberFormatter.string(from: NSNumber(value: amount)) ?? "Rp\(total)"
//    }
//}
