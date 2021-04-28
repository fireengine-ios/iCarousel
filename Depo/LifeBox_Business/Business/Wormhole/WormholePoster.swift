//
//  WormholePoster.swift
//  LifeboxShared
//
//  Created by Bondar Yaroslav on 4/11/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import MMWormhole

final class WormholePoster {
    
    private(set) lazy var wormhole: MMWormhole = MMWormhole(applicationGroupIdentifier: SharedConstants.groupIdentifier, optionalDirectory: SharedConstants.wormholeDirectoryIdentifier)
    
    func logout() {
        wormhole.passMessageObject(nil, identifier: SharedConstants.wormholeLogout)
    }
    
    func didLogout() {
        wormhole.passMessageObject(nil, identifier: SharedConstants.wormholeDidLogout)
    }
    
    func offTurkcellPassword() {
        wormhole.passMessageObject(nil, identifier: SharedConstants.wormholeOffTurkcellPassword)
    }
}
