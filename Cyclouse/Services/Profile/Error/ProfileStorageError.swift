//
//  ProfileStorageError.swift
//  Cyclouse
//
//  Created by yoga arie on 24/11/24.
//

import Foundation


// MARK: - Error Types
enum ProfileStorageError: LocalizedError {
    case unauthorized
    case compressionFailed
    case loadFailed
    case metadataNotFound
    
    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "User not logged in"
        case .compressionFailed:
            return "Failed to compress image"
        case .loadFailed:
            return "Failed to load profile image"
        case .metadataNotFound:
            return "Profile image metadata not found"
        }
    }
