//
//  NetmeraShareEvent.swift
//  Depo
//
//  Created by Alex on 1/8/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Netmera

extension NetmeraEvents {
    
    final class NetmeraShareEvent: NetmeraEvent {
        
        private let kShareKey = "bkv"
        
        @objc var method = ""
        @objc var channelType = ""

        convenience init(method: String, channelType: String) {
            self.init()
            self.method = method
            self.channelType = channelType
        }
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [
                "ea" : #keyPath(method),
                "eb" : #keyPath(channelType),
            ]
        }
        
        override var eventKey : String {
            return kShareKey
        }
    }
    
}
