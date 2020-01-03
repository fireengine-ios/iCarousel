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
        
        @objc var status: String = ""
        @objc var loginType: String = ""

//        init(status: String, loginType: String) {
//            super.init()
//            
//        }
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return[
                "ea" : #keyPath(status),//NSStringFromSelector(#selector(getter: self.status)),
                "eb" : #keyPath(loginType),//NSStringFromSelector(#selector(getter: self.loginType)),
            ]
        }
        override var eventKey : String {
            return kLoginKey
        }
    }
}
