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
    
    func goToHelpAndSupport()
    
    func goToTermsAndPolicy()
    
    func goToAgreements()
        
    func goToPermissions()
    //Photo related methods - below
    func onChangeUserPhoto(quotaInfo: QuotaInfoResponse?)
        
    func onChooseFromPhotoLibriary<T: UIViewController>(onViewController viewController: T) where T: UIImagePickerControllerDelegate & UINavigationControllerDelegate
    func onChooseFromPhotoCamera<T: UIViewController>(onViewController viewController: T) where T: UIImagePickerControllerDelegate & UINavigationControllerDelegate
    
    func photoCaptured(data: Data)
    
    func goToActivityTimeline()
 
    func goToPasscodeSettings(needReplaceOfCurrentController: Bool)
    
    func openPasscode(handler: @escaping VoidHandler)
    
    func goTurkcellSecurity()
    
    func goToMyProfile(userInfo: AccountInfoResponse)
    
    func presentErrorMessage(errorMessage: String)
    
    func presentActionSheet(alertController: UIAlertController)
    
    var isPasscodeEmpty: Bool { get }
    
    var isPremiumUser: Bool { get }

//    func turkcellSecurityStatusNeeded(passcode: Bool, autoLogin: Bool)
//    func turkcellSecurityChanged(passcode: Bool, autoLogin: Bool)
//
    var isMailRequired: Bool { get }
    var isTurkCellUser: Bool { get }
}
