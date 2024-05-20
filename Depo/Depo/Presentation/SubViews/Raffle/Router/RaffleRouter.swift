//
//  RaffleRouter.swift
//  Depo
//
//  Created by Ozan Salman on 26.03.2024.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import Foundation

class RaffleRouter: RaffleRouterInput {

    let router = RouterVC()
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    
    func goToRaffleSummary(statusResponse: RaffleStatusResponse?, campaignId: Int) {
        let vc = router.raffleSummary(statusResponse: statusResponse, campaignId: campaignId)
        router.pushViewController(viewController: vc, animated: false)
    }
    
    func goToRaffleCondition(statusResponse: RaffleStatusResponse?, conditionImageUrl: String, campaignId: Int) {
        let vc = router.raffleCondition(statusResponse: statusResponse, conditionImageUrl: conditionImageUrl, campaignId: campaignId)
        router.pushViewController(viewController: vc, animated: false)
    }
    
    func goToPages(raffle: RaffleElement) {
        analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .click, eventLabel: .gamificationEvent(raffle))
        switch raffle {
        case .login:
            print("aaaaaaaaaaaa login")
        case .purchasePackage:
            router.pushViewController(viewController: router.myStorage(usageStorage: nil))
        case .photopick:
            let controller = router.analyzesHistoryController()
            router.pushViewController(viewController: controller)
        case .createCollage:
            let vc = router.createCollage()
            router.pushViewController(viewController: vc)
        case .photoPrint:
            let isHavePrintPackage = SingletonStorage.shared.accountInfo?.photoPrintPackage ?? false
            let sendRemaining = SingletonStorage.shared.accountInfo?.photoPrintSendRemaining ?? 0
            if !isHavePrintPackage {
                let vc = PhotoPrintNoPackagePopup.with()
                vc.open()
            } else if sendRemaining == 0 {
                let vc = PhotoPrintNoRightPopup.with()
                vc.open()
            } else {
                let vc = router.photoPrintSelectPhotos(popupShowing: true)
                router.pushViewController(viewController: vc, animated: false)
            }
        case .createStory:
            let controller = router.createStory(navTitle: TextConstants.createStory)
            router.pushViewController(viewController: controller)
        case .createAlbum:
            let vc = router.createNewAlbum()
            router.pushViewController(viewController: vc)
        case .faceImage:
            let vc = router.faceImage
            router.pushViewController(viewController: vc)
        case .fotoVideoUpload:
            let vc = router.uploadPhotos()
            let navigation = NavigationController(rootViewController: vc)
            navigation.navigationBar.isHidden = false
            router.presentViewController(controller: navigation)
        case .inviteSignup:
            let vc = router.invitationController()
            router.pushViewController(viewController: vc)
        }
    }
}
