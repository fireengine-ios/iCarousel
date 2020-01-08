//
//  NetmeraDownloadEvent.swift
//  Depo
//
//  Created by Alex on 1/8/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Netmera

extension NetmeraEvents {
    
    final class NetmeraDownloadEvent: NetmeraEvent {
        
        private let kDownloadKey = "wgb"
        
        @objc var type = ""
        @objc var count: Int = 0

        convenience init(type: String, count: Int) {
            self.init()
            self.type = type
            self.count = count
        }
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [
                "ea" : #keyPath(type),
                "ec" : #keyPath(count),
            ]
        }
        
        override var eventKey : String {
            return kDownloadKey
        }
    }
    
}
