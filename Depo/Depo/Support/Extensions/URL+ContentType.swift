//
//  URL+ContentType.swift
//  Depo
//
//  Created by Bondar Yaroslav on 2/28/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import MobileCoreServices

extension URL {
    var imageContentType: String {
        let type = pathExtension.lowercased()
        
        if !type.isEmpty {
            return "image/\(type)"
        } else if let data = try? Data(contentsOf: self) {
            return ImageFormat.get(from: data).contentType
        } else {
            return "image/jpg" 
        }
    }
}

extension URL {
    
    /// UTI
    /// https://stackoverflow.com/a/34772517/5893286
    var utType: String? {
        return (try? resourceValues(forKeys: [.typeIdentifierKey]))?.typeIdentifier
    }
    
    var mimeType: String {
        if let uti = utType,
            let mimetype = UTTypeCopyPreferredTagWithClass(uti as CFString, kUTTagClassMIMEType)?.takeRetainedValue() {
            return mimetype as String
        }
        return "application/octet-stream"
    }
}
