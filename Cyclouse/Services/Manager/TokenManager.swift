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
      let hasToken = getToken() != nil
      let hasUserId = getCurrentUserId() != nil
      print("Auth State - Has Token: \(hasToken), Has UserId: \(hasUserId)")
      return hasToken && hasUserId
  }
  
  func getCurrentUserId() -> String? {
          do {
              return try valet.string(forKey: "currentUserId")
          } catch {
              print("Failed to retrieve user ID: \(error)")
              return nil
          }
      }
      
      func setCurrentUserId(_ userId: String) {
          do {
              try valet.setString(userId, forKey: "currentUserId")
            print("UserId saved successfully: \(userId)")
          } catch {
              print("Failed to store user ID: \(error)")
          }
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
  
  // MARK: - Login Method
    func saveLoginData(token: String, userId: String) {
        setToken(token)
        setCurrentUserId(userId)
        print("Login data saved - Token and UserId")
    }
    
  
     func setOnboardingComplete() {
         do {
             try valet.setString("completed", forKey: "hasSeenOnboarding")
         } catch {
             print("Failed to store onboarding state: \(error)")
         }
     }
}
