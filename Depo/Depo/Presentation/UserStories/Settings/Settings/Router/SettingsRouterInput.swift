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

    func goToInvitation()

    func goToConnectedAccounts()
    
    func goToPermissions()
    
    func goToAutoUpload()
    
    func goToPeriodicContactSync()
    
    func goToFaceImage()
    
    func goToHelpAndSupport()
    
    func goToTermsAndPolicy()
    
    func goToUserInfo(userInfo: AccountInfoResponse)
    
    func goToActivityTimeline()
    
    func goToPackagesWith(quotaInfo: QuotaInfoResponse?)

    func goToPremium()
    
    func goToPasscodeSettings(isTurkcell: Bool, inNeedOfMail: Bool, needReplaceOfCurrentController: Bool)
    
    func closeEnterPasscode()
    
    func openPasscode(handler: @escaping VoidHandler)

    func goToConnectedToNetworkFailed()
        
    func showMailUpdatePopUp(delegate: MailVerificationViewControllerDelegate?)
    
    func showError(errorMessage: String)
    
    func presentAlertSheet(alertController: UIAlertController)

    func goToChatbot()
    
    func goToFeedback()
    
    func goToPackages()

    func goToDarkMode()
    
    func goToPaycellCampaing()
    
    func goToNotification()
    
    func goToConnectedDevice()
}
