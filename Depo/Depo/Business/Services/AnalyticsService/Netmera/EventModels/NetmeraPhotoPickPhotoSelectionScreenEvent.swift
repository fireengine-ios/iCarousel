//
//  NetmeraPhotoPickPhotoSelectionScreenEvent.swift
//  Depo
//
//  Created by Alex on 1/8/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Netmera

extension NetmeraEvents {
    
    final class NetmeraPhotoPickPhotoSelectionScreenEvent: NetmeraEvent {
        
        private let kPhotoPickPhotoSelectionScreenKey = "wtj"
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [:]
        }
        
        override var eventKey : String {
            return kPhotoPickPhotoSelectionScreenKey
        }
    }
    
}
