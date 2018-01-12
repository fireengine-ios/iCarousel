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
    
    func goToUserInfo(userInfo: AccountInfoResponse, isTurkcellUser: Bool) {
        router.pushViewController(viewController: router.userProfile(userInfo: userInfo, isTurkcellUser: isTurkcellUser))
    }
    
    func goToActivityTimeline() {
        router.pushViewController(viewController: router.vcActivityTimeline)
    }
    
    func goToPackages() {
        router.pushViewController(viewController: router.packages)
    }
    
    func goToPasscodeSettings(isTurkcell: Bool, inNeedOfMail: Bool) {
        router.pushViewController(viewController: router.passcodeSettings(isTurkcell: isTurkcell, inNeedOfMail: inNeedOfMail))
    }
    
    func closeEnterPasscode() {
        router.popViewController()
    }
    
    func openPasscode(handler: @escaping () -> Void) {
        let vc = PasscodeEnterViewController.with(flow: .validate, navigationTitle: TextConstants.passcodeLifebox)
        
        vc.success = { [weak self] in
            self?.router.navigationController?.popViewController(animated: false)
            handler()
        }
        router.pushViewController(viewController: vc)
    }
    
    func goToConnectedToNetworkFailed() {
        UIApplication.showErrorAlert(message: TextConstants.errorConnectedToNetwork)
    }
    
    func goTurkcellSecurity() {
        router.pushViewController(viewController: router.turkcellSecurity)
    }
    
    func showMailUpdatePopUp(delegate: MailVerificationViewControllerDelegate?) {
        let mailController = MailVerificationViewController()
        mailController.actionDelegate = delegate
        mailController.modalPresentationStyle = .overFullScreen
        mailController.modalTransitionStyle = .crossDissolve
        router.presentViewController(controller: mailController)//.present(mailController, animated: true, completion: nil)
    }
}
