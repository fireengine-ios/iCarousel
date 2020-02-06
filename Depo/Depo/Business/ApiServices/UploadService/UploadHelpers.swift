//
//  UploadHelpers.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 11/10/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

enum MetaSpesialFolder: String {
    case MOBILE_UPLOAD = "MOBILE_UPLOAD"
    case CROPY = "CROPY"
    case none = ""
}

enum UploadType {
    case simpleUpload
    case resumableUpload
    case autoSync
    case syncToUse
}

enum MetaStrategy: String {
    case ConflictControl = "0"
    case WithoutConflictControl = "1"
}
