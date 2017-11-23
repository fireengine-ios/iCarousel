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
    
    var name: String {
        return asset.value(forKey: "filename") as! String
    }
    
    var dateOfCreation: Date? {
        return asset.creationDate
    }
    
    var lastModifiedDate: Date? {
        return asset.modificationDate
    }
    
    var hashValue: Int {
        return (urlToFile).hashValue
    }
    
    init(curentAsset: PHAsset, urlToFile: URL, size:UInt64, md5: String) {
        self.asset = curentAsset
        self.urlToFile = urlToFile
        self.size = Int64(size)
        self.md5 = md5
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
}

func == (left: BaseMediaContent, right: BaseMediaContent) -> Bool {
    return left.urlToFile == right.urlToFile
}
