//
//  NetmeraEmailVerificationEvent.swift
//  Depo
//
//  Created by Alex on 1/8/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Netmera

extension NetmeraEvents {
    
    final class NetmeraEmailVerificationEvent: NetmeraEvent {
        
        private let kEmailVerificationKey = "axi"
        
        @objc var action = ""
        
        convenience init(action: String) {
            self.init()
            self.action = action
        }
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return[
                "ea" : #keyPath(action),
            ]
        }
        
        override var eventKey : String {
            return kEmailVerificationKey
        }
    }
    
}
