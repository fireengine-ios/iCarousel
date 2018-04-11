//
//  WormholeListener.swift
//  LifeboxShared
//
//  Created by Bondar Yaroslav on 4/11/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import MMWormhole

final class WormholeListener {
    
    static let shared = WormholeListener()
    
    private let authtService = AuthenticationService()
    private let accountService = AccountService()
    
    func startListen() {
        listenLogout()
        listenOffTurkcellPassword()
    }
    
    private (set) lazy var wormhole: MMWormhole = {
        MMWormhole(applicationGroupIdentifier: SharedConstants.groupIdentifier,
                   optionalDirectory: SharedConstants.wormholeDirectoryIdentifier)
    }()
    
    //    private lazy var defaults: UserDefaults? = {
    //        UserDefaults(suiteName: SharedConstants.groupIdentifier)
    //    }()
    //    
    //    private (set) var totalCount: Int {
    //        get { return defaults?.integer(forKey: SharedConstants.totalAutoSyncCountKey) ?? 0 }
    //        set { defaults?.set(newValue, forKey: SharedConstants.totalAutoSyncCountKey) }
    //    }
    
    private func listenLogout() {
        wormhole.listenForMessage(withIdentifier: SharedConstants.wormholeLogout) { [weak self] _ in
            self?.authtService.logout {
                DispatchQueue.main.async {
                    let router = RouterVC()
                    router.setNavigationController(controller: router.onboardingScreen)
                }
            }
        }
    }
    
    private func listenOffTurkcellPassword() {
        wormhole.listenForMessage(withIdentifier: SharedConstants.wormholeOffTurkcellPassword) { [weak self] _ in
            self?.accountService.securitySettingsChange(turkcellPasswordAuthEnabled: false, mobileNetworkAuthEnabled: false, success: nil, fail: nil)
        }
    }
}
