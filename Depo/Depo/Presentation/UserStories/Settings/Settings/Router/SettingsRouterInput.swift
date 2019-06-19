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
    
    func goToConnectedAccounts()
    
    func goToPermissions()
    
    func goToAutoApload()
    
    func goToPeriodicContactSync()
    
    func goToFaceImage()
    
    func goToHelpAndSupport()
    
    func goToUsageInfo()
    
    func goToUserInfo(userInfo: AccountInfoResponse, isTurkcellUser: Bool)
    
    func goToActivityTimeline()
    
    func goToPackagesWith(quotaInfo: QuotaInfoResponse?)

    func goToPremium()
    
    func goToPasscodeSettings(isTurkcell: Bool, inNeedOfMail: Bool, needReplaceOfCurrentController: Bool)
    
    func closeEnterPasscode()
    
    func openPasscode(handler: @escaping VoidHandler)

    func goToConnectedToNetworkFailed()
    
    func goTurkcellSecurity()
    
    func showMailUpdatePopUp(delegate: MailVerificationViewControllerDelegate?)
    
    func showError(errorMessage: String)
}
