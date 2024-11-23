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
    private let valet = Valet.valet(with: Identifier(nonEmpty: "com.yourapp.auth")!,
                                   accessibility: .whenUnlocked)
    private let userProfileSubject = CurrentValueSubject<UserProfile?, Never>(nil)
    private let imageManager = ProfileImageManager.shared
    
    var userProfilePublisher: AnyPublisher<UserProfile?, Never> {
        userProfileSubject.eraseToAnyPublisher()
    }
    
    func loadUserProfile() {
        print("📝 Loading user profile")
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            do {
                let profileData = try self.valet.object(forKey: "userProfile")
                let userProfile = try JSONDecoder().decode(UserProfile.self, from: profileData)
                print("✅ User profile loaded successfully")
                self.userProfileSubject.send(userProfile)
                
                if let userId = TokenManager.shared.getCurrentUserId() {
                    print("👤 Current user ID:", userId)
                    Task {
                        print("🔄 Loading profile image for user")
                        try? await self.imageManager.loadProfileImage(for: userId)
                    }
                } else {
                    print("⚠️ No user ID available when loading profile")
                }
            } catch {
                print("❌ Failed to load user profile:", error.localizedDescription)
                self.userProfileSubject.send(nil)
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
