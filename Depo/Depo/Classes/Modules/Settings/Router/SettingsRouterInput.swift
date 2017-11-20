//
//  SettingsSettingsRouterInput.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol SettingsRouterInput {
    
    func goToOnboarding()
    
    func goToContactSync()
    
    func goToImportPhotos()
    
    func goToAutoApload()
    
    func goToHelpAndSupport()
    
    func goToUsageInfo()
    
    func goToUserInfo(userInfo: AccountInfoResponse)
    
    func goToActivityTimeline()
    
    func goToPackages()
    
    func goToPasscode(delegate: PasscodeEnterDelegate?, type: PasscodeInputViewType)
    
    func goToPasscodeSettings()
    
    func closeEnterPasscode()

    func goToConnectedToNetworkFailed()

}
