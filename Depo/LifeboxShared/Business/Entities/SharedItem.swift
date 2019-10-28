//
//  SharedItem.swift
//  LifeboxShared
//
//  Created by Bondar Yaroslav on 2/27/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

protocol SharedItem {
    var image: UIImage { get }
    var name: String { get }
    var contentType: String { get }
}

protocol SharedUrl: SharedItem {
    var url: URL { get }
}

protocol SharedData: SharedItem {
    var data: Data { get }
}

enum SharedItemSource {
    case url(SharedUrl)
    case data(SharedData)
}
extension SharedItemSource: Equatable {
    static func ==(lhs: SharedItemSource, rhs: SharedItemSource) -> Bool {
        switch (lhs, rhs) {
        case (.url, .data), (.data, .url):
            return false
        case (.url(let lhsItem), .url(let rhsItem)):
            return lhsItem.url == rhsItem.url
        case (.data(let lhsItem), .data(let rhsItem)):
            return lhsItem.data == rhsItem.data
        }
    }
}

final class SharedImage: SharedData {
    
    let image: UIImage
    let data: Data
    let contentType: String
    let name: String
    
    init?(image: UIImage) {
        self.image = image
        let baseName = UUID().uuidString
        
        if let jpgData = UIImageJPEGRepresentation(image, 1) {
            data = jpgData
            contentType = "image/jpg"
            name = "\(baseName).jpg"
        } else if let pngData = UIImagePNGRepresentation(image) {
            data = pngData
            contentType = "image/png"
            name = "\(baseName).png"
        } else {
            return nil
        }
    }
}

extension SharedImage: Equatable {
    public static func ==(lhs: SharedImage, rhs: SharedImage) -> Bool {
        return lhs.image == rhs.image
    }
}

class SharedFileUrl: SharedUrl {
    let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    /// not in the extension bcz of error:
    /// "Overriding non-@objc declarations from extensions is not supported"
    var image: UIImage {
        return Images.noDocuments
    }
    
    var name: String {
        return url.lastPathComponent
    }
    
    var contentType: String {
        return url.mimeType
    }
}


extension SharedFileUrl: Equatable {
    public static func ==(lhs: SharedFileUrl, rhs: SharedFileUrl) -> Bool {
        return lhs.url == rhs.url
    }
}

final class SharedImageUrl: SharedFileUrl {
    
    override var image: UIImage {
        guard
            let data = try? Data(contentsOf: url),
            let image = UIImage(data: data)
        else {
            return Images.noDocuments
        }
        return image
    }
    
    override var contentType: String {
        return url.imageContentType
    }
}

final class SharedVideo: SharedFileUrl {
    override var image: UIImage {
        return url.videoPreview ?? Images.noDocuments
    }
    
    override var contentType: String {
        return "video/mp4"
    }
}
