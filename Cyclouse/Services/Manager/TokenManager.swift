//
//  TokenManager.swift
//  Cyclouse
//
//  Created by yoga arie on 01/10/24.
//
import Valet
import Foundation


final class TokenManager {
    static let shared = TokenManager()
    private let valetService: ValetServiceProtocol
    
    private init(valetService: ValetServiceProtocol = ValetService.shared) {
        self.valetService = valetService
    }
    
    // MARK: - Auth Methods
    func getToken() -> String? {
        try? valetService.retrieveString(for: .authToken)
    }
    
    func setToken(_ token: String) {
        try? valetService.saveString(token, for: .authToken)
    }
    
    func getCurrentUserId() -> String? {
        try? valetService.retrieveString(for: .userId)
    }
    
    func setCurrentUserId(_ userId: String) {
        try? valetService.saveString(userId, for: .userId)
    }
    
    func isLoggedIn() -> Bool {
        let hasToken = getToken() != nil
        let hasUserId = getCurrentUserId() != nil
        return hasToken && hasUserId
    }
    
    // MARK: - Session Methods
    func saveLoginData(token: String, userId: String) {
        setToken(token)
        setCurrentUserId(userId)
        print("✅ Login data saved successfully")
    }
    
    func logout() {
        try? valetService.remove(.authToken)
        try? valetService.remove(.userId)
        try? valetService.remove(.userProfile)
        print("✅ Logout successful - All data cleared")
    }
    
    // MARK: - Onboarding Methods
    func hasSeenOnboarding() -> Bool {
        (try? valetService.retrieveString(for: .onboarding)) != nil
    }
    
    func setOnboardingComplete() {
        try? valetService.saveString("completed", for: .onboarding)
    }
}
