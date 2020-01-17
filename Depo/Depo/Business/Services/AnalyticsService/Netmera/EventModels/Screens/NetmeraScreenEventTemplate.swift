//
//  NetmeraScreenEventTemplate.swift
//  Depo
//
//  Created by Alex on 1/9/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Netmera

class NetmeraScreenEventTemplate: NetmeraEvent {
    
    private(set) var key: String = ""
    
    override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
        return [:]
    }
    
    override var eventKey : String {
        return key
    }
}
