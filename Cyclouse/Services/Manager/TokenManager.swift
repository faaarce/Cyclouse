//
//  TokenManager.swift
//  Cyclouse
//
//  Created by yoga arie on 01/10/24.
//
import Valet
import Foundation

class TokenManager {
  static let shared = TokenManager()
  private let valet: Valet
  
  private init() {
    self.valet = Valet.valet(with: Identifier(nonEmpty: "com.yourapp.auth")!, accessibility: .whenUnlocked)
  }
  
  func getToken() -> String? {
         do {
             return try valet.string(forKey: "authToken")
         } catch {
             print("Failed to retrieve auth token: \(error)")
             return nil
         }
     }
     
     func setToken(_ token: String) {
         do {
           print(token)
             try valet.setString(token, forKey: "authToken")
         } catch {
             print("Failed to store auth token: \(error)")
         }
     }
  
  func isLoggedIn() -> Bool {
    return getToken() != nil
  }
  
  
  func logout() {
    do {
      try valet.removeObject(forKey: "authToken")
    } catch {
      print("Error during logout: \(error)")
    }
  }
  
  func hasSeenOnboarding() -> Bool {
         do {
             return try valet.string(forKey: "hasSeenOnboarding") != nil
         } catch {
             print("Failed to retrieve onboarding state: \(error)")
             return false
         }
     }
     
     func setOnboardingComplete() {
         do {
             try valet.setString("completed", forKey: "hasSeenOnboarding")
         } catch {
             print("Failed to store onboarding state: \(error)")
         }
     }
}
