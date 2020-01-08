//
//  NetmeraWelcomePage5Event.swift
//  Depo
//
//  Created by Alex on 1/8/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Netmera

extension NetmeraEvents {
    
    final class WelcomePage5: NetmeraEvent {
        
        private let kWelcomePage5Key = "ujh"
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [:]
        }
        
        override var eventKey : String {
            return kWelcomePage5Key
        }
    }
    
}
