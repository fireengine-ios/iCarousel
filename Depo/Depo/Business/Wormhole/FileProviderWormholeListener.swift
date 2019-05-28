//
//  FileProviderWormholeListener.swift
//  LifeboxFileProvider
//
//  Created by 12345 on 5/27/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation
import MMWormhole

 class FileProviderWormholeListener {
    
    private var logoutHandler: VoidHandler?
    
    private(set) lazy var wormhole: MMWormhole = MMWormhole(applicationGroupIdentifier: SharedConstants.groupIdentifier, optionalDirectory: SharedConstants.wormholeDirectoryIdentifier)
    
    func listenDidLogout(logoutHandler: @escaping VoidHandler) {
        self.logoutHandler = logoutHandler
        wormhole.listenForMessage(withIdentifier: SharedConstants.wormholeDidLogout) { [weak self] _ in
            self?.logoutHandler?()
        }
    }
}
