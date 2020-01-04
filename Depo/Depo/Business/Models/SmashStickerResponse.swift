//
//  SmashStickerResponse.swift
//  Depo
//
//  Created by Maxim Soldatov on 1/3/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation
import SwiftyJSON


enum StickerType: String {
    case gif = "SMASH_ANIMATION"
    case image = "SMASH_STICKER"
}

final class SmashStickerResponse {
    
    private enum ResponseKey {
        static let id = "id"
        static let fileName = "fileName"
        static let path = "path"
        static let type = "type"
        static let thumbnailPath = "thumbnailPath"
        static let contentType = "content_type"
    }
    
    let id: Int
    let fileName: String
    let path: URL
    let thumbnailPath: URL?
    let type: StickerType
    let contentType: String
    
    
    init(id: Int,
         fileName: String,
         path: URL,
         thumbnailPath: URL?,
         type: StickerType,
         contentType: String) {
        
        self.id = id
        self.fileName = fileName
        self.path = path
        self.thumbnailPath = thumbnailPath
        self.type = type
        self.contentType = contentType
    }

    convenience init?(json: JSON) {
        guard
            let id = json[ResponseKey.id].int,
            let fileName = json[ResponseKey.fileName].string,
            let path = json[ResponseKey.path].url,
            let type = StickerType(rawValue: json[ResponseKey.type].stringValue),
            let contentType = json[ResponseKey.contentType].string
        else {
            return nil
        }
        
        let thumbnailPath = json[ResponseKey.thumbnailPath].url
        
        self.init(id: id,
                  fileName: fileName,
                  path: path,
                  thumbnailPath: thumbnailPath,
                  type: type,
                  contentType: contentType)
    }
}

