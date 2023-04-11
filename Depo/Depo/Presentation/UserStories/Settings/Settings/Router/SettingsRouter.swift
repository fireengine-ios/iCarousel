//
//  SettingsSettingsRouter.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class SettingsRouter: SettingsRouterInput {

    let router = RouterVC()
    
    func goToOnboarding() {
        router.setNavigationController(controller: router.onboardingScreen)
    }

    func goToInvitation() {
        router.pushViewController(viewController: router.invitation)
    }
    
    func goToPaycellCampaing() {
        router.pushViewController(viewController: router.paycell)
    }

    func goToConnectedAccounts() {
        router.pushViewController(viewController: router.connectedAccounts!)
    }
    
    func goToPermissions() {
        router.pushViewController(viewController: router.permissions)
    }
    
    func goToAutoUpload() {
        router.pushViewController(viewController: router.autoUpload)
    }
    
    func goToPeriodicContactSync() {
        router.pushViewController(viewController: router.periodicContactsSync)
    }
    
    func goToFaceImage() {
        router.pushViewController(viewController: router.faceImage)
    }

    func goToHelpAndSupport() {
        router.pushViewController(viewController: router.helpAndSupport)
    }
    
    func goToTermsAndPolicy() {
        router.pushViewController(viewController: router.termsAndPolicy!)
    }
    
    func goToUserInfo(userInfo: AccountInfoResponse) {
        router.pushViewController(viewController: router.userProfile(userInfo: userInfo))
    }
    
    func goToActivityTimeline() {
        router.pushViewController(viewController: router.vcActivityTimeline)
    }
    
    func goToPackagesWith(quotaInfo: QuotaInfoResponse?) {
        let vc = router.packages(quotaInfo: quotaInfo)
        router.pushViewController(viewController: vc)
    }
    
    func goToPackages() {
        router.pushViewController(viewController: router.myStorage(usageStorage: nil))
    }
    
    func goToNotification() {
        let vc = router.notification()
        router.pushViewController(viewController: vc)
    }
    
    func goToPremium() {
        router.pushViewController(viewController: router.premium())
    }
    
    func goToPasscodeSettings(isTurkcell: Bool, inNeedOfMail: Bool, needReplaceOfCurrentController: Bool) {
        let vc = router.passcodeSettings(isTurkcell: isTurkcell, inNeedOfMail: inNeedOfMail)
        if needReplaceOfCurrentController {
            router.pushViewControllerAndRemoveCurrentOnCompletion(vc)
        } else {
            router.pushViewController(viewController: vc)
        }
    }
    
    func closeEnterPasscode() {
        router.popViewController()
    }
    
    func openPasscode(handler: @escaping VoidHandler) {
        let vc = PasscodeEnterViewController.with(flow: .validate, navigationTitle: TextConstants.passcodeLifebox)
        vc.success = {
            handler()
        }
        
        router.pushViewController(viewController: vc)
    }
    
    func goToConnectedToNetworkFailed() {
        UIApplication.showErrorAlert(message: TextConstants.errorConnectedToNetwork)
    }
    
    func showMailUpdatePopUp(delegate: MailVerificationViewControllerDelegate?) {
        let mailController = MailVerificationViewController()
        mailController.actionDelegate = delegate
        mailController.modalPresentationStyle = .overFullScreen
        mailController.modalTransitionStyle = .crossDissolve
        router.presentViewController(controller: mailController)//.present(mailController, animated: true, completion: nil)
    }
    
    func showError(errorMessage: String) {
        UIApplication.showErrorAlert(message: errorMessage)
    }
    
    func presentAlertSheet(alertController: UIAlertController) {
        router.presentViewController(controller: alertController)
    }

    func goToChatbot() {
        router.pushViewController(viewController: router.chatbot)
    }
    
    func goToFeedback() {
        router.showFeedbackSubView()
    }

    func goToDarkMode() {
    }
}
