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
    
    func goToRaffleSummary(statusResponse: RaffleStatusResponse?) {
        let vc = router.raffleSummary(statusResponse: statusResponse)
        router.pushViewController(viewController: vc, animated: false)
    }
    
    func goToRaffleCondition(statusResponse: RaffleStatusResponse?) {
        let vc = router.raffleCondition(statusResponse: statusResponse)
        router.pushViewController(viewController: vc, animated: false)
    }
    
    func goToPages(raffle: RaffleElement) {
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
            let vc = router.photoPrintSelectPhotos()
            router.pushViewController(viewController: vc)
        case .createStory:
            let controller = router.createStory(navTitle: TextConstants.createStory)
            router.pushViewController(viewController: controller)
        case .createAlbum:
            let vc = router.createNewAlbum()
            router.pushViewController(viewController: vc)
        case .faceImage:
            print("aaaaaaaaaaaa faceImage")
        case .fotoVideoUpload:
            print("aaaaaaaaaaaa fotoVideoUpload")
        case .inviteSignup:
            print("aaaaaaaaaaaa inviteSignup")
        }
    }
}
