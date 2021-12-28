//
//  DragAndDropFileExtensions.swift
//  Depo
//
//  Created by Burak Donat on 27.12.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation
import MobileCoreServices

enum DragAndDropFileExtensions: String, CaseIterable {
    case png = "png"
    case jpeg = "jpeg"
    case heic = "heic"
    case gif = "gif"
    case mp4 = "mp4"
    case mov = "mov"
    
    var isImageType: Bool {
        switch self {
        case .png, .jpeg, .heic , .gif:
            return true
        default:
            return false
        }
    }
    
    var isVideoType: Bool {
        switch self {
        case .mp4, .mov:
            return true
        default:
            return false
        }
    }
}
