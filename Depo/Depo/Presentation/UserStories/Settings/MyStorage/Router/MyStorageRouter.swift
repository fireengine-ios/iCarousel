//
//  MyStorageRouter.swift
//  Depo
//
//  Created by Raman Harhun on 11/27/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class MyStorageRouter {
    private let router = RouterVC()
    weak var delegate: MyStoragePresenter?
}

//MARK: - MyStorageRouterInput
extension MyStorageRouter: MyStorageRouterInput {
    
    
    func showCancelOfferAlert(with text: String) {
        let vc = PopUpController.with(title: TextConstants.offersInfo, message: text, image: .none, buttonTitle: TextConstants.offersOk)
        vc.open()
    }
    
    func showCancelOfferApple() {
        let alertVC = UIAlertController(title: TextConstants.offersInfo, message: TextConstants.offersAllCancel, preferredStyle: .alert)
        alertVC.view.tintColor = UIColor.lrTealish

        let okAction = UIAlertAction(title: TextConstants.offersOk, style: .cancel, handler: nil)
        let settingsAction = UIAlertAction(title: TextConstants.offersSettings, style: .default) { _ in
            UIApplication.shared.openSettings()
        }
        
        alertVC.addAction(settingsAction)
        alertVC.addAction(okAction)
        router.presentViewController(controller: alertVC)
    }
    
    func showSubTurkcellOpenAlert(with text: String) {
        let vc = PopUpController.with(title: TextConstants.offersInfo, message: text, image: .none, buttonTitle: TextConstants.offersOk)
        vc.open()
    }
    
    func openLeavePremium(type: LeavePremiumType) {
        let vc = router.leavePremium(type: type)
        router.pushViewController(viewController: vc)
    }
    
    func display(error: String) {
        UIApplication.showErrorAlert(message: error)
    }
    
    func openTermsOfUse() {
        router.pushViewController(viewController: router.termsOfUseScreen)
    }
    
    func showSuccessPurchasedPopUp(with delegate: MyStoragePresenter) {
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
    
    func closePaymentPopUpController(closeAction: @escaping VoidHandler) {
        if let paymentPopUpController = router.defaultTopController as? PaymentPopUpController {
            paymentPopUpController.close(completion: closeAction)
        } else {
            assertionFailure("there is no PaymentPopUpController. check requirements or logic")
            UIApplication.topController()?.dismiss(animated: true, completion: closeAction)
        }
    }
}
