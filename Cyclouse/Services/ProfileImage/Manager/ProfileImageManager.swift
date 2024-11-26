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




class ProfileImageManager {
    static let shared = ProfileImageManager()
    
    private let memoryCache: NSCache<NSString, UIImage>
    private let fileManager: FileManager
    private let databaseService: DatabaseService
    private let valet: Valet
    
    private init() {
        self.memoryCache = NSCache<NSString, UIImage>()
        self.memoryCache.countLimit = 1
        self.fileManager = FileManager.default
        self.databaseService = DatabaseService.shared
        self.valet = Valet.valet(with: Identifier(nonEmpty: "com.yourapp.auth")!,
                                accessibility: .whenUnlocked)
        
        createImageDirectory()
    }
    
    private func createImageDirectory() {
        do {
            let documentsPath = try fileManager.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            ).appendingPathComponent("ProfileImages")
            
            if !fileManager.fileExists(atPath: documentsPath.path) {
                try fileManager.createDirectory(
                    at: documentsPath,
                    withIntermediateDirectories: true
                )
                print("✅ Created ProfileImages directory")
            }
        } catch {
            print("❌ Failed to create directory: \(error)")
        }
    }

    func saveProfileImage(_ image: UIImage, for userId: String) async throws {
        print("📸 Starting save for userId:", userId)
        
        guard TokenManager.shared.isLoggedIn() else {
            print("❌ Not logged in")
            throw ProfileStorageError.unauthorized
        }
        
        // 1. Save to FileSystem
        let imageUrl = try await saveToFileSystem(image, userId: userId)
        print("💾 Saved to filesystem:", imageUrl.path)
        
        // 2. Cache in Memory
        memoryCache.setObject(image, forKey: userId as NSString)
        print("💭 Cached in memory")
        
        // 3. Store metadata
        let metadata = ProfileImageMetadata(
            userId: userId,
            imagePath: imageUrl.path,
            imageSize: Int64(try Data(contentsOf: imageUrl).count)
        )
        
        try await saveMetadata(metadata)
        print("📝 Metadata saved")
        
        // 4. Store path in Valet
        try valet.setString(imageUrl.path, forKey: "profile_image_path_\(userId)")
        print("🔐 Path saved in Valet")
        
        print("✅ Save completed successfully")
    }
    
    private func saveToFileSystem(_ image: UIImage, userId: String) async throws -> URL {
        print("📁 Saving to filesystem...")
        let filename = "profile_\(userId)_\(Date().timeIntervalSince1970).jpg"
        
        let documentsPath = try fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ).appendingPathComponent("ProfileImages")
        
        let imageUrl = documentsPath.appendingPathComponent(filename)
        print("📍 Target path:", imageUrl.path)
        
        let optimizedImage = image.resizeForProfile()
        guard let imageData = optimizedImage.jpegData(compressionQuality: 0.7) else {
            print("❌ Compression failed")
            throw ProfileStorageError.compressionFailed
        }
        
        try imageData.write(to: imageUrl)
        print("✅ File written successfully")
        return imageUrl
    }
    
    func loadProfileImage(for userId: String) async throws -> UIImage? {
        print("🔍 Loading image for userId:", userId)
        
        guard TokenManager.shared.isLoggedIn() else {
            print("❌ Not logged in")
            return nil
        }
        
        // 1. Check Memory Cache
        if let cachedImage = memoryCache.object(forKey: userId as NSString) {
            print("✅ Found in memory cache")
            return cachedImage
        }
        
        // 2. Check Valet path
        if let savedPath = try? valet.string(forKey: "profile_image_path_\(userId)") {
            print("📍 Found path in Valet:", savedPath)
            if fileManager.fileExists(atPath: savedPath),
               let image = UIImage(contentsOfFile: savedPath) {
                print("✅ Loaded from Valet path")
                memoryCache.setObject(image, forKey: userId as NSString)
                return image
            } else {
                print("⚠️ File not found at Valet path")
            }
        }
        
        // 3. Try metadata
        do {
            let metadata = try await getMetadata(for: userId)
            print("📍 Found path in metadata:", metadata.imagePath)
            
            if fileManager.fileExists(atPath: metadata.imagePath),
               let image = UIImage(contentsOfFile: metadata.imagePath) {
                print("✅ Loaded from metadata path")
                memoryCache.setObject(image, forKey: userId as NSString)
                return image
            } else {
                print("⚠️ File not found at metadata path")
            }
        } catch {
            print("⚠️ Metadata lookup failed:", error)
        }
        
        // 4. Last resort: Check directory
        do {
            let documentsPath = try fileManager.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            ).appendingPathComponent("ProfileImages")
            
            let files = try fileManager.contentsOfDirectory(
                at: documentsPath,
                includingPropertiesForKeys: nil
            )
            
            print("📁 Files in directory:", files.map { $0.lastPathComponent })
            
            let userFiles = files.filter { $0.lastPathComponent.contains(userId) }
            print("🔍 Files for this user:", userFiles.map { $0.lastPathComponent })
            
            if let latestFile = userFiles.sorted(by: { $0.path > $1.path }).first,
               let image = UIImage(contentsOfFile: latestFile.path) {
                print("✅ Found latest file in directory")
                memoryCache.setObject(image, forKey: userId as NSString)
                
                // Update metadata and Valet
                try valet.setString(latestFile.path, forKey: "profile_image_path_\(userId)")
                let metadata = ProfileImageMetadata(
                    userId: userId,
                    imagePath: latestFile.path,
                    imageSize: Int64(try Data(contentsOf: latestFile).count)
                )
                try await saveMetadata(metadata)
                return image
            }
        } catch {
            print("⚠️ Directory check failed:", error)
        }
        
        print("❌ No image found")
        return nil
    }
    
    private func saveMetadata(_ metadata: ProfileImageMetadata) async throws {
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
    }
    
    private func setupSchema() {
        // DatabaseService already handles the schema setup
        print("Using existing DatabaseService for SwiftData operations")
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
