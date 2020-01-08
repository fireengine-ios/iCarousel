//
//  NetmeraImportEvent.swift
//  Depo
//
//  Created by Alex on 1/8/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Netmera

extension NetmeraEvents {
    
    final class NetmeraImportEvent: NetmeraEvent {
        
        private let kImportKey = "qfv"
        
        @objc var channelType = ""
        @objc var status = ""
        
        convenience init(status: String, channelType: String) {
            self.init()
            self.status = status
            self.channelType = channelType
        }
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return[
                "ea" : #keyPath(status),
                "eb" : #keyPath(channelType),
            ]
        }
        
        override var eventKey : String {
            return kImportKey
        }
    }
    
}
