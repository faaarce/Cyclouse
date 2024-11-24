//
//  AppConfig.swift
//  Cyclouse
//
//  Created by yoga arie on 12/09/24.
//

import Foundation

struct AppConfig {
    static var current: AppConfig = .init()
    
    #if DEBUG
  var environment: Environment = .development  // or .development
    #else
    var environment: Environment = .production
    #endif
}
