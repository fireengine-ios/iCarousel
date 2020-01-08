//
//  NetmeraPhotoPickAnalysisDetailScreenEvent.swift
//  Depo
//
//  Created by Alex on 1/8/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Netmera

extension NetmeraEvents {
    
    final class NetmeraPhotoPickAnalysisDetailScreenEvent: NetmeraEvent {
        
        private let kPhotoPickAnalysisDetailScreenKey = "hup"
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [:]
        }
        
        override var eventKey : String {
            return kPhotoPickAnalysisDetailScreenKey
        }
    }
    
}
