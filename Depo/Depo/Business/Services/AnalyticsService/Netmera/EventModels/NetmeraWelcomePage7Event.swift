//
//  NetmeraWelcomePage7Event.swift
//  Depo
//
//  Created by Alex on 1/8/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Netmera

extension NetmeraEvents {
    
    final class NetmeraWelcomePage7Event: NetmeraEvent {
        
        private let kWelcomePage7Key = "vbt"
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [:]
        }
        
        override var eventKey : String {
            return kWelcomePage7Key
        }
    }
    
}
