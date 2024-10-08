//
//  Codable + Dictionary.swift
//  TaskManagement
//
//  Created by Phincon on 18/07/24.
//

import Foundation
extension Encodable {
    func toDictionary() -> [String: Any]? {
        do {
            let data = try JSONEncoder().encode(self)
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            return jsonObject as? [String: Any]
        } catch {
            print("Encoding error: \(error)")
            return nil
        }
    }
}

