//
//  UploadHelpers.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 11/10/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

enum MetaSpesialFolder: String {
    case ROOT = ""
    case CROPY = "CROPY"
}

enum UploadType {
    case regular
    case sharedWithMe
    case sharedArea
}

enum MetaStrategy: String {
    case ConflictControl = "0"
    case WithoutConflictControl = "1"
}
