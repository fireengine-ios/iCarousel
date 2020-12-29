//
//  NetmeraServiceExtention.swift
//  Depo
//
//  Created by Alex Developer on 26.05.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Netmera

///This class is used for event logs requred in APP Extensions, such as shared and files, so we dont have to include unneded types and unrelated operations
final class NetmeraExtensionsService {
    
    enum OnOffSettings: String {
        case on
        case off
        
        var text: String {
            switch self {
            case .on:
                return "On"
            case .off:
                return "Off"
            }
        }
    }
    
    static func sendEvent(event: NetmeraEvent) {
        Netmera.send(event)
    }
    
}

final class PasscodeSet: NetmeraEvent {
    
    private let key = "nrx"
    @objc var action = ""
    
    convenience init(isEnabled: Bool) {
        self.init(action: isEnabled ? .on : .off)
    }
    
    convenience init(action: NetmeraExtensionsService.OnOffSettings) {
        self.init()
        self.action = action.text
    }
    
    override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
        return[
            "ea" : #keyPath(action),
        ]
    }
    override var eventKey : String {
        return key
    }
}

final class TouchidSet: NetmeraEvent {
    private let key = "lit"
    @objc var action = ""
    
    convenience init(isEnabled: Bool) {
        self.init(action: isEnabled ? .on : .off)
    }
    
    convenience init(action: NetmeraExtensionsService.OnOffSettings) {
        self.init()
        self.action = action.text
    }
    
    override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
        return[
            "ea" : #keyPath(action),
        ]
    }
    override var eventKey : String {
        return key
    }
}
