//
//  BaseFileModel.swift
//  Depo
//
//  Created by Oleg on 29.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit
import Photos
import MediaPlayer
import Foundation

enum LocationMediaContent {
    case local
    case iCloud
}

class BaseMediaContent: Equatable, Hashable {
    
    let urlToFile: URL
    
    let md5: String
    
    let size: Int64
    
    let asset: PHAsset
    
    let originalName: String
    
    var location: LocationMediaContent {
        // TODO:
        return .local
    }
    
    var fileType: FileType {
        
        switch asset.mediaType {
            case .image   : return .image
            case .video   : return .video
            case .audio   : return .audio
            case .unknown : return .unknown
        }
    }

    var dateOfCreation: Date? {
        return asset.creationDate
    }
    
    var lastModifiedDate: Date? {
        return asset.modificationDate
    }

    init(curentAsset: PHAsset, generalInfo: AssetInfo) {
        self.asset = curentAsset
        self.urlToFile = generalInfo.url
        self.size = generalInfo.size
        self.md5 = generalInfo.md5
        self.originalName = generalInfo.name
        
    }

    func getCellReUseID() -> String {
        switch self.fileType {
        case .video:
            return CollectionViewCellsIdsConstant.cellForVideo
            
        case .image:
            return CollectionViewCellsIdsConstant.cellForImage
            
        case .audio:
            return CollectionViewCellsIdsConstant.cellForAudio
            
        default:
            return CollectionViewCellsIdsConstant.cellForImage
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(urlToFile)
    }
}

func == (left: BaseMediaContent, right: BaseMediaContent) -> Bool {
    return left.urlToFile == right.urlToFile
}
