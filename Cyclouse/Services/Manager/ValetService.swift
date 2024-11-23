//
//  ValetService.swift
//  Cyclouse
//
//  Created by yoga arie
//

import Valet
import Foundation
import UIKit

// MARK: - Valet Keys Enum
enum ValetKey: String, CaseIterable {
    case authToken = "authToken"
    case userId = "currentUserId"
    case userProfile = "userProfile"
    case onboarding = "hasSeenOnboarding"
}

// MARK: - Valet Service Protocol
protocol ValetServiceProtocol {
    func save<T: Encodable>(_ value: T, for key: ValetKey) throws
    func retrieve<T: Decodable>(_ type: T.Type, for key: ValetKey) throws -> T?
    func saveString(_ value: String, for key: ValetKey) throws
    func retrieveString(for key: ValetKey) throws -> String?
    func remove(_ key: ValetKey) throws
    func removeAll() throws
}

// MARK: - Valet Service Implementation
final class ValetService: ValetServiceProtocol {
    static let shared = ValetService()
    
    private let valet: Valet
    
    private init() {
        self.valet = Valet.valet(with: Identifier(nonEmpty: "com.cyclouse.auth")!,
                                accessibility: .whenUnlocked)
    }
    
    // MARK: - Save Methods
    func save<T: Encodable>(_ value: T, for key: ValetKey) throws {
        let data = try JSONEncoder().encode(value)
        try valet.setObject(data, forKey: key.rawValue)
    }
    
    func saveString(_ value: String, for key: ValetKey) throws {
        try valet.setString(value, forKey: key.rawValue)
    }
    
    // MARK: - Retrieve Methods
    func retrieve<T: Decodable>(_ type: T.Type, for key: ValetKey) throws -> T? {
        guard let data = try? valet.object(forKey: key.rawValue) else {
            return nil
        }
        return try JSONDecoder().decode(type, from: data)
    }
    
    func retrieveString(for key: ValetKey) throws -> String? {
        try valet.string(forKey: key.rawValue)
    }
    
    // MARK: - Remove Methods
    func remove(_ key: ValetKey) throws {
        try valet.removeObject(forKey: key.rawValue)
    }
    
    func removeAll() throws {
        try ValetKey.allCases.forEach { key in
            try? remove(key)
        }
    }
}

// MARK: - Error Types
enum ValetError: LocalizedError {
    case saveError(Error)
    case retrieveError(Error)
    case encodingError(Error)
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .saveError(let error): return "Failed to save: \(error.localizedDescription)"
        case .retrieveError(let error): return "Failed to retrieve: \(error.localizedDescription)"
        case .encodingError(let error): return "Failed to encode: \(error.localizedDescription)"
        case .decodingError(let error): return "Failed to decode: \(error.localizedDescription)"
        }
    }
}
