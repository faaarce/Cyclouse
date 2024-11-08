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
            return ""
        }
    }
}

/*
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
     
     // Add debug description to help during development
     var debugDescription: String {
         switch self {
         case .development:
             return "Development (localhost)"
         case .staging:
             return "Staging (ngrok)"
         case .production:
             return "Production"
         }
     }
 }

 enum DevelopmentMode {
     case local     // Uses localhost
     case staging   // Uses ngrok
 }

 struct AppConfig {
     static var current: AppConfig = .init()
     
     #if DEBUG
     // Automatically choose environment based on device type
     static var developmentMode: DevelopmentMode {
         #if targetEnvironment(simulator)
         return .local     // Simulator will use localhost
         #else
         return .staging   // Real device will use ngrok
         #endif
     }
     
     var environment: Environment {
         switch AppConfig.developmentMode {
         case .local:
             return .development
         case .staging:
             return .staging
         }
         
         // Print current environment for debugging
         print("🔧 Current environment: \(environment.debugDescription)")
     }
     #else
     var environment: Environment = .production
     #endif
 }
 */
