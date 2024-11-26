//
//  ProfileViewModel.swift
//  Cyclouse
//
//  Created by yoga arie on 17/11/24.
//
import Foundation
import Combine
import Valet
import UIKit

class ProfileViewModel {
    private let valetService: ValetServiceProtocol
    private let userProfileSubject = CurrentValueSubject<UserProfiles?, Never>(nil)
    private let imageManager = ProfileImageManager.shared
    
    var userProfilePublisher: AnyPublisher<UserProfiles?, Never> {
        userProfileSubject.eraseToAnyPublisher()
    }
    
    init(valetService: ValetServiceProtocol = ValetService.shared) {
        self.valetService = valetService
    }
    
    func loadUserProfile() {
        print("📝 Loading user profile")
        Task {
            do {
                if let userProfile: UserProfiles = try valetService.retrieve(UserProfiles.self, for: .userProfile) {
                    print("✅ User profile loaded successfully")
                    userProfileSubject.send(userProfile)
                    
                    if let userId = TokenManager.shared.getCurrentUserId() {
                        print("👤 Loading profile image for user:", userId)
                        try? await imageManager.loadProfileImage(for: userId)
                    }
                } else {
                    print("⚠️ No user profile found")
                    userProfileSubject.send(nil)
                }
            } catch {
                print("❌ Failed to load user profile:", error.localizedDescription)
                userProfileSubject.send(nil)
            }
        }
    }
    
    func saveProfileImage(_ image: UIImage) async throws {
        print("💾 Attempting to save profile image")
        guard let userId = TokenManager.shared.getCurrentUserId() else {
            print("❌ No user ID available for saving image")
            throw ProfileStorageError.unauthorized
        }
        
        print("👤 Saving image for user:", userId)
        try await imageManager.saveProfileImage(image, for: userId)
        print("✅ Image saved successfully")
    }
    
    func loadProfileImage() async throws -> UIImage? {
        print("🔄 Loading profile image")
        guard let userId = TokenManager.shared.getCurrentUserId() else {
            print("❌ No user ID available for loading image")
            return nil
        }
        
        print("👤 Loading image for user:", userId)
        let image = try await imageManager.loadProfileImage(for: userId)
        print(image == nil ? "⚠️ No image found" : "✅ Image loaded successfully")
        return image
    }
}
// MARK: - Error Extension
extension ProfileStorageError {
  var displayMessage: String {
      switch self {
      case .unauthorized:
          return "Please log in to update your profile picture"
      case .compressionFailed:
          return "Failed to process image. Please try again"
      case .loadFailed:
          return "Couldn't load profile picture"
      case .metadataNotFound:
          return "Profile picture information not found"
      }
  }
}
