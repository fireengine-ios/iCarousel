//
//  NetmeraPackageClickEvent.swift
//  Depo
//
//  Created by Alex on 1/9/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Netmera

extension NetmeraEvents {
    
    final class NetmeraPackageClickEvent: NetmeraEvent {
        
        private let kPackageClickKey = "hzp"
        
        @objc var packageName = ""

        convenience init(packageName: String) {
            self.init()
            self.packageName = packageName
        }
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [
                "ee" : #keyPath(packageName),
            ]
        }
        
        override var eventKey : String {
            return kPackageClickKey
        }
    }
    
}
