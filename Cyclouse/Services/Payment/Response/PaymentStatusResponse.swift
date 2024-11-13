//
//  PaymentStatusResponse.swift
//  Cyclouse
//
//  Created by yoga arie on 12/11/24.
//

import Foundation

struct PaymentStatusResponse: Responseable {
  let success: Bool
   let data: PaymentStatusData
   let message: String
}

struct PaymentStatusData: Codable {
   let orderId: String
   let updatedAt: String
   let status: String
}
