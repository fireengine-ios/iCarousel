//
//  PackagesPackagesRouter.swift
//  Depo
//
//  Created by Yaroslav Bondar on 20/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class PackagesRouter {
    private let router = RouterVC()
}

// MARK: PackagesRouterInput
extension PackagesRouter: PackagesRouterInput {

    func openTermsOfUse() {
        router.pushViewController(viewController: router.termsOfUseScreen)
    }

    func openLeavePremium() {
        let vc = router.leavePremium(title: TextConstants.lifeboxPremium, activeSubscriptions: [])
        router.pushViewController(viewController: vc)
    }
    
    func openMyStorage(storageUsage: UsageResponse?) {
        let viewController = router.myStorage(usageStorage: storageUsage)
        router.pushViewController(viewController: viewController)
    }
}
