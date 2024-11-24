//
//  LocationError.swift
//  Cyclouse
//
//  Created by yoga arie on 24/11/24.
//

import Foundation

enum LocationError: Error {
    case serviceDisabled
    case addressNotFound
    case permissionDenied
    case unknown(Error)
    
    var localizedDescription: String {
        switch self {
        case .serviceDisabled:
            return "Location services are disabled"
        case .addressNotFound:
            return "Could not find address for this location"
        case .permissionDenied:
            return "Location permission denied"
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

