//
//  NetmeraWelcomePage6Event.swift
//  Depo
//
//  Created by Alex on 1/8/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Netmera

extension NetmeraEvents {
    
    final class NetmeraWelcomePage6Event: NetmeraEvent {
        
        private let kWelcomePage6Key = "xxz"
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [:]
        }
        
        override var eventKey : String {
            return kWelcomePage6Key
        }
    }
    
}
