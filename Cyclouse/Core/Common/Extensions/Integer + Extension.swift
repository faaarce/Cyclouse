//
//  Integer + Extension.swift
//  Cyclouse
//
//  Created by yoga arie on 12/10/24.
//

import Foundation

extension Int {
    func toRupiah() -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0

        if let formattedPrice = formatter.string(from: NSNumber(value: self)) {
            let adjustedPrice = formattedPrice.replacingOccurrences(of: "Rp", with: "Rp ")
            return adjustedPrice
        } else {
            return "Rp 0"
        }
    }
}


