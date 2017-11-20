//
//  SettingsSettingsViewOutput.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol SettingsViewOutput: PasscodeEnterDelegate {

    func viewIsReady()
    
    func onLogout()
    
    func goToContactSync()
    
    func goToImportPhotos()

    func goToAutoApload()
    
    func goToHelpAndSupport()
    
    func goToUsageInfo()
    //Photo related methods - below
    func onChangeUserPhoto()
    
    func onUpdatUserInfo(userInfo: AccountInfoResponse)
    
    func onChooseFromPhotoLibriary(onViewController viewController: UIViewController)
    func onChooseFromPhotoCamera(onViewController viewController: UIViewController)
    
    func photoCaptured(data: Data)
    
    func goToActivityTimeline()
    
    func goToPackages()
    
    func goToPasscode(delegate: PasscodeEnterDelegate?, type: PasscodeInputViewType)
    
    func goToPasscodeSettings()
}
