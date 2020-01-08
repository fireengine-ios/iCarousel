//
//  NetmeraFirstAutosyncEvent.swift
//  Depo
//
//  Created by Alex on 1/8/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Netmera

extension NetmeraEvents {
    
    final class NetmeraFirstAutosyncEvent: NetmeraEvent {
        
        private let kFirstAutosyncKey = "ekh"
        
        @objc var syncSetting = ""
        @objc var photos = ""
        @objc var videos = ""

        convenience init(syncSetting: String, photos: String, videos: String) {
            self.init()
            self.syncSetting = syncSetting
            self.photos = photos
            self.videos = videos
        }
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [
                "ee" : #keyPath(syncSetting),
                "ea" : #keyPath(photos),
                "eb" : #keyPath(videos),
            ]
        }
        
        override var eventKey : String {
            return kFirstAutosyncKey
        }
    }
    
}
