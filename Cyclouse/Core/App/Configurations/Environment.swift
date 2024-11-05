//
//  Environment.swift
//  Cyclouse
//
//  Created by yoga arie on 12/09/24.
//

import Foundation

enum Environment {
    case development
    case staging
    case production
    
    var baseURL: String {
        switch self {
        case .development:
            return "http://localhost:8080"
        case .staging:
            return "https://4f7d-182-253-54-18.ngrok-free.app"
        case .production:
            return "your-production-url"
        }
    }
}
