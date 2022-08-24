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
        
        successPopUp.open()

    }
    
    func closePaymentPopUpController(closeAction: @escaping VoidHandler) {
        if let paymentPopUpController = router.defaultTopController as? PaymentPopUpController {
            paymentPopUpController.close(completion: closeAction)
        } else {
            assertionFailure("there is no PaymentPopUpController. check requirements or logic")
            UIApplication.topController()?.dismiss(animated: true, completion: closeAction)
        }
    }
    
    func showPaycellProcess(with cpcmOfferId: Int) {
        let controller = PaycellViewController.create(with: cpcmOfferId) { result in
            switch result {
            case .success():
                UIApplication.showSuccessAlert(message: TextConstants.successfullyPurchased)
            case .failed(_):
                UIApplication.showErrorAlert(message: TextConstants.errorUnknown)
            }
        }
        router.pushViewController(viewController: controller)
    }
}
