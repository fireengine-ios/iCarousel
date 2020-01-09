//
//  NetmeraWelcomePage3Event.swift
//  Depo
//
//  Created by Alex on 1/9/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Netmera

extension NetmeraEvents {
    
    final class NetmeraWelcomePage3Event: NetmeraEvent {
        
        private let kWelcomePage3Key = "wow"
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [:]
        }
        
        override var eventKey : String {
            return kWelcomePage3Key
        }
    }
    
}
