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
    
    private lazy var tokenStorage: TokenStorage = factory.resolve()
    private lazy var passcodeStorage: PasscodeStorage = factory.resolve()
    private lazy var biometricsManager: BiometricsManager = factory.resolve()
    
    private var logoutHandler: VoidHandler?
    
    private(set) lazy var wormhole: MMWormhole = MMWormhole(applicationGroupIdentifier: SharedConstants.groupIdentifier, optionalDirectory: SharedConstants.wormholeDirectoryIdentifier)
    
    func listenLogout(logoutHandler: @escaping VoidHandler) {
        self.logoutHandler = logoutHandler
        wormhole.listenForMessage(withIdentifier: SharedConstants.wormholeDidLogout) { [weak self] _ in
            guard let `self` = self else {
                return
            }
            self.tokenStorage.clearTokens()
            self.passcodeStorage.clearPasscode()
            self.biometricsManager.isEnabled = false
            self.logoutHandler?()
        }
    }
}
