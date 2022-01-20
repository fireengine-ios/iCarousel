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
    ///images
    case png  = "png"
    case jpeg = "jpeg"
    case heic = "heic"
    case gif  = "gif"
    
    ///music
    case mp3 = "mp3"
    
    ///videos
    case mp4 = "mp4"
    case mov = "mov"
    
    ///documents
    case zip     = "zip"
    case unknown = "unknown"
    case doc     = "doc"
    case txt     = "txt"
    case html    = "html"
    case xls     = "xls"
    case pdf     = "pdf"
    case ppt     = "ppt"
    case pptx    = "pptx"
    case usdz    = "usdz"
    case docx    = "docx"
    case xlsx    = "xlsx"
    
    var isPhotoVideoType: Bool? {
        switch self {
        case .png, .jpeg, .heic, .gif, .mp4, .mov:
            return true
        default:
            return false
        }
    }
}
