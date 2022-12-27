//
//  PackagesPackagesRouter.swift
//  Depo
//
//  Created by Yaroslav Bondar on 20/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class PackagesRouter {
    private let router = RouterVC()
    weak var delegate: PackagesPresenter?
}

// MARK: PackagesRouterInput
extension PackagesRouter: PackagesRouterInput {
    func openMyStorage(usageStorage: UsageResponse?) {
        let viewController = router.myStorage(usageStorage: usageStorage)
        router.pushViewController(viewController: viewController)
    }
    
    func openUsage() {
        guard let userInfo = router.usageInfo else {
            assertionFailure()
            return
        }
        router.pushViewController(viewController: userInfo)
    }
    
    func openUserProfile(userInfo: AccountInfoResponse, isTurkcellUser: Bool) {
        let viewController = router.userProfile(userInfo: userInfo, isTurkcellUser: isTurkcellUser)
        router.pushViewController(viewController: viewController)
    }
    
    func goToConnectedAccounts() {
        router.pushViewController(viewController: router.connectedAccounts!)
    }
}
