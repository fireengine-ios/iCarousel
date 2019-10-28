//
//  ShareData.swift
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

protocol SharedUrl2: SharedItem {
    var url: URL { get }
}

protocol SharedData2: SharedItem {
    var data: Data { get }
}

enum SharedItem2 {
    case url(SharedUrl2)
    case data(SharedData2)
}
extension SharedItem2: Equatable {
    static func ==(lhs: SharedItem2, rhs: SharedItem2) -> Bool {
        
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

final class SharedImage: SharedData2 {
    
    let image: UIImage
    let data: Data
    let contentType: String
    let name: String
    
    init?(image: UIImage) {
        self.image = image
        let baseName = UUID().uuidString
        
        if let pngData = UIImagePNGRepresentation(image) {
            data = pngData
            contentType = "image/png"
            name = "\(baseName).png"
        } else if let jpgData = UIImageJPEGRepresentation(image, 1) {
            data = jpgData
            contentType = "image/jpg"
            name = "\(baseName).jpg"
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

class SharedUrl: SharedUrl2 {
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


extension SharedUrl: Equatable {
    public static func ==(lhs: SharedUrl, rhs: SharedUrl) -> Bool {
        return lhs.url == rhs.url
    }
}

final class SharedImageUrl: SharedUrl {
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
        return "video/mp4"
    }
}

final class SharedVideo: SharedUrl {
    override var image: UIImage {
        return url.videoPreview ?? Images.noDocuments
    }
    
    override var contentType: String {
        return url.imageContentType
    }
}




open class ShareData {
    let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    var image: UIImage? {
        return Images.noDocuments
    }
    
    var name: String {
        return url.lastPathComponent
    }
    
    var contentType: String {
        let contentType: String
        
        if self is ShareImage {
            contentType = url.imageContentType
        } else if self is ShareVideo {
            contentType = "video/mp4"
        } else {
            contentType = url.mimeType
        }
        return contentType
    }
}
extension ShareData: Equatable {
    public static func ==(lhs: ShareData, rhs: ShareData) -> Bool {
        return lhs.url == rhs.url
    }
}

final class ShareImage: ShareData {
    override var image: UIImage? {
        guard
            let data = try? Data(contentsOf: url),
            let image = UIImage(data: data)
        else {
            return nil
        }
        return image
    }
}

final class ShareVideo: ShareData {
    override var image: UIImage? {
        return url.videoPreview
    }
}
