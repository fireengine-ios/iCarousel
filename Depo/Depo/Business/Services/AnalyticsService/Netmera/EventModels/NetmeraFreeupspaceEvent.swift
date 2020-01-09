//
//  NetmeraFreeupspaceEvent.swift
//  Depo
//
//  Created by Alex on 1/9/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Netmera

extension NetmeraEvents {
    
    final class NetmeraFreeupspaceEvent: NetmeraEvent {
        
        private let kFreeupspaceKey: String = "kxj"
        
        @objc var count: Int = 0
        
        convenience init(count: Int) {
            self.init()
            self.count = count
        }
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return ["ec" : #keyPath(count)]
        }
        
        override var eventKey : String {
            return kFreeupspaceKey
        }
    }
    
}
