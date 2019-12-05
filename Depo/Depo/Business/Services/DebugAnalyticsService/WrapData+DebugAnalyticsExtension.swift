//
//  WrapData+DebugAnalyticsExtension.swift
//  Depo
//
//  Created by Konstantin Studilin on 04/12/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation


extension WrapData {
    func toDebugAnalyticsAttributes() -> [String : Any] {
        return [
            "isImage" : fileType == .image,
            "trimmedLocalId" : getTrimmedLocalID(),
            "isLocal" : isLocalItem
        ]
    }
}
