//
//  SettingsSettingsRouter.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class SettingsRouter: SettingsRouterInput {
    
    let router = RouterVC()
    
    func goToOnboarding(){
        router.setNavigationController(controller: router.onboardingScreen)
    }
    
    func goToContactSync(){
        router.pushViewController(viewController:router.syncContacts!)
    }
    
    func goToImportPhotos() {
        router.pushViewController(viewController:router.importPhotos!)
    }
    
    func goToAutoApload(){
        router.pushViewController(viewController: router.autoUpload)
    }

    func goToHelpAndSupport(){
        router.pushViewController(viewController: router.helpAndSupport!)
    }
    
    func goToUsageInfo() {
        router.pushViewController(viewController: router.usageInfo!)
    }
    
    func goToUserInfo(userInfo: AccountInfoResponse) {
        router.pushViewController(viewController: router.userProfile(userInfo: userInfo))
    }
    
    func goToActivityTimeline() {
        router.pushViewController(viewController: router.vcActivityTimeline)
    }
    
    func goToPackages() {
        router.pushViewController(viewController: router.packages)
    }
    
    func goToPasscode(delegate: PasscodeEnterDelegate?, type: PasscodeInputViewType) {
        router.pushViewController(viewController: router.passcode(delegate: delegate, type: type))
    }
    
    func goToPasscodeSettings() {
        router.pushViewController(viewController: router.passcodeSettings())
    }
    
    func closeEnterPasscode() {
        router.popViewController()

    }
    
    func goToConnectedToNetworkFailed() {
        CustomPopUp.sharedInstance.showCustomAlert(withText: TextConstants.errorConnectedToNetwork,
                                                   okButtonText:TextConstants.ok)
    }
    
}
