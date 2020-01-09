//
//  NetmeraPhotoPickHistoryScreenEvent.swift
//  Depo
//
//  Created by Alex on 1/9/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Netmera

extension NetmeraEvents {
    
    final class NetmeraPhotoPickHistoryScreenEvent: NetmeraEvent {
        
        private let kPhotoPickHistoryScreenKey = "dzx"
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [:]
        }
        
        override var eventKey : String {
            return kPhotoPickHistoryScreenKey
        }
    }
    
}
