//
//  ShareWormholeListener.swift
//  LifeboxShared
//
//  Created by Bondar Yaroslav on 4/11/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import MMWormhole

final class ShareWormholeListener {
    
    private (set) lazy var wormhole: MMWormhole = {
        MMWormhole(applicationGroupIdentifier: SharedConstants.groupIdentifier,
                   optionalDirectory: SharedConstants.wormholeDirectoryIdentifier)
    }()
    
    private var logoutHandler: VoidHandler?
    
    func listenLogout(logoutHandler: @escaping VoidHandler) {
        self.logoutHandler = logoutHandler
        wormhole.listenForMessage(withIdentifier: SharedConstants.wormholeLogout) { [weak self] _ in
            self?.logoutHandler?()
        }
    }
}
