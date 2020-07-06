//
//  PremiumRouter.swift
//  Depo_LifeTech
//
//  Created by Harbros 3 on 11/16/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class PremiumRouter {
    
    private let viewControllerForPresentOn: UIViewController?
    private let router = RouterVC()
    weak var delegate: PremiumPresenter?
    
    init(viewControllerForPresentOn: UIViewController?) {
        self.viewControllerForPresentOn = viewControllerForPresentOn
    }
}

// MARK: - PremiumRouterInput
extension PremiumRouter: PremiumRouterInput {

    func goToBack() {
        if  let controller = viewControllerForPresentOn as? InstaPickCampaignViewController {
            controller.closeAfterBecomPremium()
        } else {
            router.popViewController()
        }
    }
    
    func displayError(with errorMessage: String) {
        UIApplication.showErrorAlert(message: errorMessage)
    }
    
    func displayNoInternetError(with message: String) {
        let popUp = PopUpController.with(
            title: TextConstants.errorAlert,
            message: message,
            image: .error,
            buttonTitle: TextConstants.ok,
            action: { vc in
                vc.close { [weak self] in
                    self?.router.popViewController()
                }
        })
        router.presentViewController(controller: popUp)
    }
    
    func showNoDetailsAlert(with message: String) {
        let vc = DarkPopUpController.with(title: TextConstants.offersInfo,
                                          message: message,
                                          buttonTitle: TextConstants.ok)
        router.presentViewController(controller: vc)
    }
    
    func showPromocodInvalideAlert(for vc: UIViewController?) {
        let popUpController = PopUpController.with(title: TextConstants.checkPhoneAlertTitle,
                                                   message: TextConstants.promocodeInvalid,
                                                   image: .error,
                                                   buttonTitle: TextConstants.ok)
        vc?.present(popUpController, animated: false, completion: nil)
    }
    
    func purchaseSuccessed(with delegate: FaceImageItemsModuleOutput?) {
        let successPopUp = PopUpController.with(title: TextConstants.success,
                                                message: TextConstants.successfullyPurchased,
                                                image: .success,
                                                buttonTitle: TextConstants.ok,
                                                action: { vc in
                                                    vc.close(completion: { [weak self] in
                                                        //dismiss optIn
                                                        self?.goToBack()
                                                        //dismiss premium
                                                        self?.goToBack()
                                                        delegate?.didReloadData()
                                                    })
        })
        router.presentViewController(controller: successPopUp)
    }
    
    func openLink(with url: URL) {
        UIApplication.shared.openURL(url)
    }
    
    func showTermsOfUse() {
        router.pushViewController(viewController: router.termsOfUseScreen)
    }
    
    func presentPaymentPopUp(paymentModel: PaymentModel?) {
        let popup = PaymentPopUpController.controllerWith(paymentModel)
        if let controller = viewControllerForPresentOn {
            controller.present(popup, animated: true)
        } else {
            router.presentViewController(controller: popup)
        }
    }
    
    func closePaymentPopUpController(closeAction: @escaping VoidHandler) {
        if let paymentPopUpController = router.defaultTopController as? PaymentPopUpController {
            paymentPopUpController.close(completion: closeAction)
        } else {
            assertionFailure("there is no PaymentPopUpController. check requirements or logic")
            UIApplication.topController()?.dismiss(animated: true, completion: closeAction)
        }
    }
    
    func showAllPackages() {
        router.pushViewController(viewController: router.packages)
    }
}
