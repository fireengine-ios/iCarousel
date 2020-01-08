//
//  NetmeraCreateStoryEvent.swift
//  Depo
//
//  Created by Alex on 1/8/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Netmera

extension NetmeraEvents {
    
    final class NetmeraCreateStoryEvent: NetmeraEvent {
        
        private let kCreateStoryKey = "wed"
        
        @objc var status = ""

        convenience init(status: String) {
            self.init()
            self.status = status
        }
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [
                "ea" : #keyPath(status),
            ]
        }
        
        override var eventKey : String {
            return kCreateStoryKey
        }
    }
    
}
