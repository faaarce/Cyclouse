//
//  ProfileImageMetadata.swift
//  Cyclouse
//
//  Created by yoga arie on 24/11/24.
//

import Foundation
import SwiftData

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
