//
//  AppWormholeListener.swift
//  LifeboxShared
//
//  Created by Bondar Yaroslav on 4/11/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import MMWormhole

final class AppWormholeListener {
    
    static let shared = AppWormholeListener()
    
    private let authtService = AuthenticationService()
    private let accountService = AccountService()
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    
    func startListen() {
        listenLogout()
        listenOffTurkcellPassword()
        listenWidgetChangeState()
    }
    
    private(set) lazy var wormhole: MMWormhole = MMWormhole(applicationGroupIdentifier: SharedConstants.groupIdentifier, optionalDirectory: SharedConstants.wormholeDirectoryIdentifier)
    
    private func listenLogout() {
        wormhole.listenForMessage(withIdentifier: SharedConstants.wormholeLogout) { [weak self] _ in
            self?.authtService.logout {
                DispatchQueue.main.async {
                    if let vc = UIApplication.topController() as? PasscodeEnterViewController {
                        vc.view.endEditing(true)
                    }
                    
                    let router = RouterVC()
                    router.setNavigationController(controller: router.loginScreen)
                }
            }
        }
    }
    
    private func listenOffTurkcellPassword() {
        wormhole.listenForMessage(withIdentifier: SharedConstants.wormholeOffTurkcellPassword) { [weak self] _ in
            
            self?.accountService.securitySettingsInfo(success: { [weak self] response in
                
                if let twoFactorAuthEnabled = (response as? SecuritySettingsInfoResponse)?.twoFactorAuthEnabled {
                    self?.accountService.securitySettingsChange(turkcellPasswordAuthEnabled: true,
                                                                mobileNetworkAuthEnabled: false,
                                                                twoFactorAuthEnabled: twoFactorAuthEnabled,
                                                                success: nil,
                                                                fail: nil)
                } else {
                    assertionFailure("server returned wrong/updated response")
                }
            }, fail: nil)
        }
    }
    
    private func listenWidgetChangeState() {
        wormhole.listenForMessage(withIdentifier: SharedConstants.wormholeNewWidgetStateIdentifier) { [weak self] value in
            guard let stateGAName = value as? String else {
                return
            }
            
            self?.analyticsService.trackCustomGAEvent(eventCategory: .functions,
                                                      eventActions: .widgetOrder,
                                                      eventLabel: .widgetOrder(stateGAName))
        }
    }
    
}
