//
//  Theme+Icon.swift
//  Cyclouse
//
//  Created by yoga arie on 14/11/24.
//

import Foundation
import UIKit
import SwiftMessages


extension Theme {
    var iconImage: UIImage? {
        switch self {
        case .success:
            return UIImage(systemName: "checkmark.circle.fill")
        case .warning:
            return UIImage(systemName: "exclamationmark.triangle.fill")
        case .error:
            return UIImage(systemName: "xmark.circle.fill")
        case .info:
            return UIImage(systemName: "info.circle.fill")
        }
    }
}
