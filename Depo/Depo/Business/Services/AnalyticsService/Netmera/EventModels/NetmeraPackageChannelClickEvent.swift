//
//  NetmeraPackageChannelClickEvent.swift
//  Depo
//
//  Created by Alex on 1/8/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Netmera

extension NetmeraEvents {
    
    final class NetmeraPackageChannelClickEvent: NetmeraEvent {
        
        private let kPackageChannelClickKey = "tvm"
        
        @objc var type = ""
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [
                "ea": #keyPath(type)
            ]
        }
        
        override var eventKey : String {
            return kPackageChannelClickKey
        }
    }
    
}
