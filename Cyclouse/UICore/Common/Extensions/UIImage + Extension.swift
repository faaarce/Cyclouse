//
//  UIImage + Extension.swift
//  Cyclouse
//
//  Created by yoga arie on 24/11/24.
//

import Foundation
import UIKit

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
