//
//  NetmeraContactUsScreenEvent.swift
//  Depo_LifeTech
//
//  Created by Alex on 1/8/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Netmera

extension NetmeraEvents {
    
    final class NetmeraContactUsScreenEvent: NetmeraEvent {
        
        private let kContactUsScreenKey = "dpv"
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [:]
        }
        
        override var eventKey : String {
            return kContactUsScreenKey
        }
    }
    
}
