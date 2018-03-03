//
//  URL+ContentType.swift
//  Depo
//
//  Created by Bondar Yaroslav on 2/28/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

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
