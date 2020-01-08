//
//  NetmeraSignupScreenEvent.swift
//  Depo
//
//  Created by Alex on 1/8/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Netmera

extension NetmeraEvents {
    
    final class NetmeraSignupScreenEvent: NetmeraEvent {
        
        private let kSignupScreenKey = "xyf"
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [:]
        }
        
        override var eventKey : String {
            return kSignupScreenKey
        }
    }
    
}
