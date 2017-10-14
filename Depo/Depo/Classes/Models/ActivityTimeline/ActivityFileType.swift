//
//  ActivityFileType.swift
//  Depo
//
//  Created by user on 9/14/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

enum ActivityFileType: String {
    case image = "IMAGE"
    case video = "VIDEO"
    case document = "DOCUMENT"
    case audio = "AUDIO"
    case directory = "DIRECTORY"
    case other = "OTHER"
}
extension ActivityFileType {
    var image: UIImage {
        switch self {
        case .image:
            return #imageLiteral(resourceName: "fileIconPhoto")
        case .video:
            return #imageLiteral(resourceName: "fileIconVideo")
        case .document:
            return #imageLiteral(resourceName: "fileIconDoc")
        case .audio:
            return #imageLiteral(resourceName: "fileIconAudio")
        case .directory:
            return #imageLiteral(resourceName: "fileIconFolder")
        case .other:
            return #imageLiteral(resourceName: "fileIconUnknown")
        }
    }
}
