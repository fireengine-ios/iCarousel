//
//  NetmeraAllFilesScreenEvent.swift
//  Depo
//
//  Created by Alex on 1/9/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Netmera

extension NetmeraEvents {
    
    final class NetmeraAllFilesScreenEvent: NetmeraEvent {
        
        private let kAllFilesScreenKey = "xqq"
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [:]
        }
        
        override var eventKey : String {
            return kAllFilesScreenKey
        }
    }
    
}
