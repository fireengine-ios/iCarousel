//
//  NetmeraLoginEvent.swift
//  Depo
//
//  Created by Alex on 12/30/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Netmera

extension NetmeraEvents {
    
    final class NetmeraLoginEvent: NetmeraEvent {
        
        private let kLoginKey = "rvw"
        
        @objc var status = ""
        @objc var loginType = ""

        convenience init(status: String, loginType: String) {
            self.init()
            self.status = status
            self.loginType = loginType
        }
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [
                "ea" : #keyPath(status),//NSStringFromSelector(#selector(getter: self.status)),
                "eb" : #keyPath(loginType),//NSStringFromSelector(#selector(getter: self.loginType)),
            ]
        }
        
        override var eventKey : String {
            return kLoginKey
        }
    }
    
}
