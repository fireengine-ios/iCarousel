//
//  NetmeraScreenEventTemplate.swift
//  Depo
//
//  Created by Alex on 1/9/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Netmera

final class NetmeraScreenEventTemplate: NetmeraEvent {
    
    private var key = ""
    
    convenience init(screenEventKey: String) {
        self.init()
        self.key = screenEventKey
    }
    
    
    override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
        return [:]
    }
    
    override var eventKey : String {
        return key
    }
}
