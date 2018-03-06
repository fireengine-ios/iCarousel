//
//  String+UTType.swift
//  LifeboxFileProvider
//
//  Created by Bondar Yaroslav on 3/6/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import MobileCoreServices

extension String {
    var utTypeFromExtension: String? {
        let pathExtension = (self as NSString).pathExtension
        if pathExtension.isEmpty {
            return nil
        }
        
        let utType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as CFString, nil)?.takeRetainedValue() as String?
        
        if utType?.hasPrefix("dyn.") == true {
            return "public.data"
        }
        return utType
    }
}
