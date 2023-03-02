//
//  SettingsSettingsViewOutput.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol SettingsViewOutput {

    func viewIsReady()
    
    func viewWillBecomeActive()
    
    func onLogout()

    func goToInvitation()
    
    func goToPaycellCampaign()

    func goToConnectedAccounts()

    func goToAutoUpload()
    
    func goToFaceImage()
    
    func goToPeriodicContactSync()
    
    func goToHelpAndSupport()
    
    func goToTermsAndPolicy()
        
    func goToPermissions()

    func goToDarkMode()
    //Photo related methods - below
    func onChangeUserPhoto(quotaInfo: QuotaInfoResponse?)
        
    func onChooseFromPhotoLibriary(onViewController viewController: UIViewController)
    func onChooseFromPhotoCamera(onViewController viewController: UIViewController)
    
    func photoCaptured(data: Data)
    
    func goToActivityTimeline()
    
    func goToPackagesWith(quotaInfo: QuotaInfoResponse?)
    
    func goToPremium()
    
    func goToPasscodeSettings(needReplaceOfCurrentController: Bool)
    
    func openPasscode(handler: @escaping VoidHandler)
    
    func goTurkcellSecurity()
    
    func goToMyProfile(userInfo: AccountInfoResponse)
    
    func presentErrorMessage(errorMessage: String)
    
    func presentActionSheet(alertController: UIAlertController)

    func goToChatbot()
    
    func goToFeedback()
    
    func goToPackages()
    
    func goToNotification()
    
    var isPasscodeEmpty: Bool { get }
    
    var isPremiumUser: Bool { get }

//    func turkcellSecurityStatusNeeded(passcode: Bool, autoLogin: Bool)
//    func turkcellSecurityChanged(passcode: Bool, autoLogin: Bool)
//
    var isMailRequired: Bool { get }
    var isTurkCellUser: Bool { get }
}
