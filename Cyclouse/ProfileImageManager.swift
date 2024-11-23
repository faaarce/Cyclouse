//
//  ProfileImageManager.swift
//  Cyclouse
//
//  Created by yoga arie on 22/11/24.
//

import SwiftData
import UIKit
import Combine
import Valet



@Model
class ProfileImageMetadata {
    var userId: String
    var imagePath: String
    var lastUpdated: Date
    var imageSize: Int64
    
    init(userId: String, imagePath: String, lastUpdated: Date = Date(), imageSize: Int64) {
        self.userId = userId
        self.imagePath = imagePath
        self.lastUpdated = lastUpdated
        self.imageSize = imageSize
    }
}


class ProfileImageManager {
    static let shared = ProfileImageManager()
    
    private let memoryCache: NSCache<NSString, UIImage>
    private let fileManager: FileManager
    private let databaseService: DatabaseService
    private let valet: Valet
    
    private init() {
        // Initialize cache
        self.memoryCache = NSCache<NSString, UIImage>()
        self.memoryCache.countLimit = 1
        
        // Initialize FileManager
        self.fileManager = FileManager.default
        
        // Use existing DatabaseService
        self.databaseService = DatabaseService.shared
        
        // Use the same Valet instance as TokenManager
        self.valet = Valet.valet(with: Identifier(nonEmpty: "com.yourapp.auth")!,
                                accessibility: .whenUnlocked)
        
        // Setup database schema
        setupSchema()
    }
    
    private func setupSchema() {
        // DatabaseService already handles the schema setup
        print("Using existing DatabaseService for SwiftData operations")
    }
  
  private func saveToFileSystem(_ image: UIImage, userId: String) async throws -> URL {
      let filename = "profile_\(userId)_\(Date().timeIntervalSince1970).jpg"
      
      // Get app's document directory
      let documentsPath = try fileManager.url(
          for: .documentDirectory,
          in: .userDomainMask,
          appropriateFor: nil,
          create: true
      ).appendingPathComponent("ProfileImages")
      
      // Create directory if needed
      try? fileManager.createDirectory(
          at: documentsPath,
          withIntermediateDirectories: true
      )
      
      let imageUrl = documentsPath.appendingPathComponent(filename)
      
      // Optimize and save image
      let optimizedImage = image.resizeForProfile()
      guard let imageData = optimizedImage.jpegData(compressionQuality: 0.7) else {
          throw ProfileStorageError.compressionFailed
      }
      
      try imageData.write(to: imageUrl)
      return imageUrl
  }
  
  func loadProfileImage(for userId: String) async throws -> UIImage? {
         // Check if logged in
         guard TokenManager.shared.isLoggedIn() else {
             return nil
         }
         
         // 1. Check Memory Cache
         if let cachedImage = memoryCache.object(forKey: userId as NSString) {
             return cachedImage
         }
         
         // 2. Try loading from saved path in Valet
         if let savedPath = try? valet.string(forKey: "profile_image_path_\(userId)"),
            let image = UIImage(contentsOfFile: savedPath) {
             memoryCache.setObject(image, forKey: userId as NSString)
             return image
         }
         
         // 3. Try loading from SwiftData metadata
         let metadata = try await getMetadata(for: userId)
         if let image = UIImage(contentsOfFile: metadata.imagePath) {
             memoryCache.setObject(image, forKey: userId as NSString)
             return image
         }
         
         return nil
     }
    
    // MARK: - Save Methods
    func saveProfileImage(_ image: UIImage, for userId: String) async throws {
        print("🔄 Saving profile image for userId:", userId)
        
        // Verify user is logged in
        guard TokenManager.shared.isLoggedIn() else {
            print("❌ User not logged in")
            throw ProfileStorageError.unauthorized
        }
        
        // 1. Save to FileSystem
        let imageUrl = try await saveToFileSystem(image, userId: userId)
        print("✅ Image saved to filesystem at:", imageUrl.path)
        
        // 2. Cache in Memory
        memoryCache.setObject(image, forKey: userId as NSString)
        print("✅ Image cached in memory")
        
        // 3. Store metadata using DatabaseService
        let metadata = ProfileImageMetadata(
            userId: userId,
            imagePath: imageUrl.path,
            imageSize: Int64(try Data(contentsOf: imageUrl).count)
        )
        
        try await withCheckedThrowingContinuation { continuation in
            databaseService.create(metadata)
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            continuation.resume()
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                    },
                    receiveValue: { _ in }
                )
        }
        
        // 4. Store path in Valet for extra security
        try valet.setString(imageUrl.path, forKey: "profile_image_path_\(userId)")
        print("✅ Image path saved in Valet")
    }
    
    // Rest of your methods remain the same, but use DatabaseService for SwiftData operations
    
    private func getMetadata(for userId: String) async throws -> ProfileImageMetadata {
        return try await withCheckedThrowingContinuation { continuation in
            databaseService.fetch(
                ProfileImageMetadata.self,
                predicate: #Predicate<ProfileImageMetadata> { metadata in
                    metadata.userId == userId
                }
            )
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished: break
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                },
                receiveValue: { results in
                    if let metadata = results.first {
                        continuation.resume(returning: metadata)
                    } else {
                        continuation.resume(throwing: ProfileStorageError.metadataNotFound)
                    }
                }
            )
        }
    }
    
    private func updateMetadata(for userId: String, imageUrl: URL) async throws {
        let attributes = try fileManager.attributesOfItem(atPath: imageUrl.path)
        let fileSize = attributes[.size] as? Int64 ?? 0
        
        // Try to get existing metadata
        do {
            let existingMetadata = try await getMetadata(for: userId)
            try await withCheckedThrowingContinuation { continuation in
                databaseService.update(existingMetadata) { metadata in
                    metadata.imagePath = imageUrl.path
                    metadata.lastUpdated = Date()
                    metadata.imageSize = fileSize
                }
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            continuation.resume()
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                    },
                    receiveValue: { _ in }
                )
            }
        } catch ProfileStorageError.metadataNotFound {
            // Create new metadata if not found
            let newMetadata = ProfileImageMetadata(
                userId: userId,
                imagePath: imageUrl.path,
                imageSize: fileSize
            )
            
            try await withCheckedThrowingContinuation { continuation in
                databaseService.create(newMetadata)
                    .sink(
                        receiveCompletion: { completion in
                            switch completion {
                            case .finished:
                                continuation.resume()
                            case .failure(let error):
                                continuation.resume(throwing: error)
                            }
                        },
                        receiveValue: { _ in }
                    )
            }
        }
    }
}

// MARK: - Error Types
enum ProfileStorageError: LocalizedError {
    case unauthorized
    case compressionFailed
    case loadFailed
    case metadataNotFound
    
    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "User not logged in"
        case .compressionFailed:
            return "Failed to compress image"
        case .loadFailed:
            return "Failed to load profile image"
        case .metadataNotFound:
            return "Profile image metadata not found"
        }
    }
}

// MARK: - UIImage Extension
extension UIImage {
    func resizeForProfile() -> UIImage {
        let maxSize: CGFloat = 500
        let ratio = min(maxSize/size.width, maxSize/size.height)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage ?? self
    }
}
