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

    func openTermsOfUse() {
        router.pushViewController(viewController: router.termsOfUseScreen)
    }

    func openLeavePremium(type: LeavePremiumType) {
        let vc = router.leavePremium(type: type)
        router.pushViewController(viewController: vc)
    }
    
    func openMyStorage(storageUsage: UsageResponse?) {
        let viewController = router.myStorage(usageStorage: storageUsage)
        router.pushViewController(viewController: viewController)
    }
    
    func openUserProfile(userInfo: AccountInfoResponse, isTurkcellUser: Bool) {
        let viewController = router.userProfile(userInfo: userInfo, isTurkcellUser: isTurkcellUser)
        router.pushViewController(viewController: viewController)
    }
    
    func showSuccessPurchasedPopUp(with delegate: PackagesPresenter) {
        self.delegate = delegate
        let successPopUp = PopUpController.with(title: TextConstants.success,
                                                message: TextConstants.successfullyPurchased,
                                                image: .success,
                                                buttonTitle: TextConstants.ok,
                                                action: { [weak self] vc in
                                                    vc.close(completion: {
                                                        guard let `self` = self, let delegate = self.delegate else { return }
                                                        //dismiss optIn
                                                        self.router.popViewController()
                                                        //dismiss premium
                                                        self.router.popViewController()
                                                        delegate.refreshPackages()
                                                    })
        })
        router.presentViewController(controller: successPopUp)
    }
    
    func showPaycellProcess(with cpcmOfferId: Int) {
        let controller = PaycellViewController.createController(with: cpcmOfferId)
        router.pushViewController(viewController: controller)
    }
}
