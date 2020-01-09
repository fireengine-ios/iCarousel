//
//  NetmeraSettingsScreenEvent.swift
//  Depo
//
//  Created by Alex on 1/9/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Netmera

extension NetmeraEvents {
    
    final class NetmeraSettingsScreenEvent: NetmeraEvent {
        
        private let kSettingsScreenKey = "tiu"
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [:]
        }
        
        override var eventKey : String {
            return kSettingsScreenKey
        }
    }
    
}
