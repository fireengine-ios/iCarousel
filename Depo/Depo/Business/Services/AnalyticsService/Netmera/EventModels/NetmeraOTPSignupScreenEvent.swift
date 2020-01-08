//
//  NetmeraOTPSignupScreenEvent.swift
//  Depo_LifeTech
//
//  Created by Alex on 1/8/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Netmera

extension NetmeraEvents {
    
    final class NetmeraOTPSignupScreenEvent: NetmeraEvent {
        
        private let kOTPSignupScreenKey = "zkx"
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [:]
        }
        
        override var eventKey : String {
            return kOTPSignupScreenKey
        }
    }
    
}
