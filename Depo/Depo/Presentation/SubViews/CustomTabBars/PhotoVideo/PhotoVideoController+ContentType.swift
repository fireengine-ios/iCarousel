//
//  PhotoVideoController+ContentType.swift
//  Depo
//
//  Created by Hady on 4/18/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

extension PhotoVideoController {
    enum ContentType {
        case photos
        case videos

        var fileType: FileType {
            switch self {
            case .photos:
                return .image
            case .videos:
                return .video
            }
        }
    }
}

extension Array where Element == PhotoVideoController.ContentType {
    func mappedToFileTypes() -> [FileType] {
        return map(\.fileType)
    }
}
