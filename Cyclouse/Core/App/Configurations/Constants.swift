//
//  Constants.swift
//  Cyclouse
//
//  Created by yoga arie on 12/09/24.
//

import Foundation

struct Constants {
    struct API {
        static let baseURL = "https://api.example.com"
        static let timeout: TimeInterval = 30
    }
    
    struct UI {
        static let cornerRadius: CGFloat = 8
        static let animationDuration: TimeInterval = 0.3
    }
    
    struct Notifications {
        static let userDidLogout = "com.yourapp.userDidLogout"
        static let networkStatusChanged = "com.yourapp.networkStatusChanged"
    }
    
    struct UserDefaultsKeys {
        static let isFirstLaunch = "isFirstLaunch"
        static let userToken = "userToken"
    }
    
    struct Cells {
        static let productCell = "ProductTableViewCell"
        static let categoryCell = "CategoryCollectionViewCell"
    }
    
    struct Segues {
        static let showDetail = "ShowDetailSegue"
        static let showProfile = "ShowProfileSegue"
    }
    
    struct ValidationRules {
        static let minPasswordLength = 8
        static let maxUsernameLength = 20
    }
  
  public static var baseURL: String {
    Bundle.main.infoDictionary?["BASE_URL"] as? String ?? ""
  }
 
}
