//
//  PackagesPackagesPresenter.swift
//  Depo
//
//  Created by Yaroslav Bondar on 20/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class PackagesPresenter {
    weak var view: PackagesViewInput?
    var interactor: PackagesInteractorInput!
    var router: PackagesRouterInput!
    
    var activeSubscriptions: [SubscriptionPlanBaseResponse] = []
    private var accountType = AccountType.all
    
    private func getAccountType(for accountType: String, subscriptionPlans: [SubscriptionPlanBaseResponse]) -> AccountType {
        if accountType == "TURKCELL" {
            return AccountType.turkcell
        } else {
            let plans = subscriptionPlans.flatMap { $0.subscriptionPlanRole }
            for plan in plans {
                if plan.hasPrefix("lifebox") {
                    return AccountType.ukranian
                } else if plan.hasPrefix("kktcell") {
                    return AccountType.cyprus
                } else if plan.hasPrefix("moldcell") {
                    return AccountType.moldovian
                }
            }
            return AccountType.all
        }
    }
    
    var referenceToken = ""
    var userPhone = ""
    var offerToBuy: OfferServiceResponse?
    var optInVC: OptInController?
}

// MARK: PackagesViewOutput
extension PackagesPresenter: PackagesViewOutput {
    
    func getAccountType() -> AccountType {
        return accountType
    }
    
    func submit(promocode: String) {
        interactor.submit(promocode: promocode)
    }
    
    func viewIsReady() {
        view?.startActivityIndicator()
        interactor.getActiveSubscriptions()
    }
    
    func didPressOn(plan: SubscriptionPlan) {
        switch accountType {
        case .turkcell:
            if let offer = plan.model as? OfferServiceResponse { /// purchase, from active subscription list
                view?.showActivateOfferAlert(for: offer)
            } else if let quota = (plan.model as? SubscriptionPlanBaseResponse)?.subscriptionPlanQuota { /// cancel
                let message = String(format: TextConstants.offersCancelTurkcell, quota.bytesString)
                view?.showCancelOfferAlert(with: message)
            }
        case .ukranian:
            view?.showCancelOfferAlert(with: TextConstants.offersCancelUkranian)
        case .cyprus:
            view?.showCancelOfferAlert(with: TextConstants.offersCancelCyprus)
        case .moldovian:
            view?.showCancelOfferAlert(with: TextConstants.offersCancelMoldcell)
        case .all:
            /// maybe will be need view?.startActivityIndicator() + stop
            if let offer = plan.model as? OfferApple {
                interactor.activate(offerApple: offer)
            } else {
                view?.showCancelOfferApple()
            }
        }
    }
    
    func buy(offer: OfferServiceResponse) {
        view?.startActivityIndicator()
        
        AccountService().info(success: { [weak self] responce in
            guard let userInfoResponse = responce as? AccountInfoResponse else { return }
            self?.userPhone = userInfoResponse.fullPhoneNumber
            self?.offerToBuy = offer
            DispatchQueue.main.async {
                self?.view?.startActivityIndicator()
                self?.interactor.getToken(for: offer)
                self?.view?.stopActivityIndicator()
            }
        }, fail: { [weak self] failResponse in
            DispatchQueue.main.async {
                self?.view?.stopActivityIndicator()
            }
        })
    }
    
    func restorePurchasesPressed() {
        interactor.restorePurchases()
    }
}

// MARK: - OptInControllerDelegate
extension PackagesPresenter: OptInControllerDelegate {
    func optInResendPressed(_ optInVC: OptInController) {
        optInVC.startActivityIndicator()
        self.optInVC = optInVC
        if let offer = offerToBuy {
            interactor.getResendToken(for: offer)
        }
    }
    
    func optInReachedMaxAttempts(_ optInVC: OptInController) {
        optInVC.showResendButton()
        optInVC.dropTimer()
        UIApplication.showErrorAlert(message: TextConstants.promocodeBlocked)
    }
    
    func optInNavigationTitle() -> String {
        return TextConstants.optInNavigarionTitle
    }
    
    func optIn(_ optInVC: OptInController, didEnterCode code: String) {
        optInVC.startActivityIndicator()
        self.optInVC = optInVC
        interactor.verifyOffer(offerToBuy, token: referenceToken, otp: code)
    }
}

// MARK: PackagesInteractorOutput
extension PackagesPresenter: PackagesInteractorOutput {
    func successedPromocode() {
        MenloworksAppEvents.onPromocodeActivated()
        view?.successedPromocode()
    }
    
    func failedPromocode(with errorString: String) {
        view?.show(promocodeError: errorString)
    }
    
    func successedJobExists(isJobExists: Bool) {
        if !isJobExists {
            view?.startActivityIndicator()
            interactor.getOffers()
        }
        view?.stopActivityIndicator()
    }
    
    func failedVerifyOffer() {
        optInVC?.stopActivityIndicator()
        optInVC?.clearCode()
        optInVC?.view.endEditing(true)
        
        if optInVC?.increaseNumberOfAttemps() == false {
            let vc = PopUpController.with(title: TextConstants.checkPhoneAlertTitle, message: TextConstants.promocodeInvalid, image: .error, buttonTitle: TextConstants.ok)
            optInVC?.present(vc, animated: false, completion: nil)
        }
    }
    
    func successedVerifyOffer() {
        optInVC?.stopActivityIndicator()
        optInVC?.resignFirstResponder()
        RouterVC().popViewController()
    }
    
    func successed(activeSubscriptions: [SubscriptionPlanBaseResponse]) {
        interactor.getAccountType()
        self.activeSubscriptions = activeSubscriptions
    }
    
    func successed(tokenForOffer: String) {
        view?.stopActivityIndicator()
        referenceToken = tokenForOffer
        
        let vc = OptInController.with(phone: userPhone)
        vc.delegate = self
        RouterVC().pushViewController(viewController: vc)
    }
    
    func successed(tokenForResend: String) {
        referenceToken = tokenForResend
        optInVC?.stopActivityIndicator()
        optInVC?.setupTimer(withRemainingTime: NumericConstants.vereficationTimerLimit)
        optInVC?.startEnterCode()
        optInVC?.hideResendButton()
    }
    
    func successed(accountTypeString: String) {
        accountType = getAccountType(for: accountTypeString, subscriptionPlans: activeSubscriptions)
        switch accountType {
        case .turkcell:
            view?.startActivityIndicator()
            interactor.checkJobExists()
        case .ukranian:
            view?.showSubTurkcellOpenAlert(with: TextConstants.offersActivateUkranian)
        case .cyprus:
            view?.showSubTurkcellOpenAlert(with: TextConstants.offersActivateCyprus)
        case .moldovian:
            break
        case .all:
            //show restore
            view?.showRestoreButton()
            /// in app purchase
            view?.showInAppPolicy()
            interactor.getOfferApples()
        }
        
        let subscriptionPlans = interactor.convertToASubscriptionList(activeSubscriptionList: activeSubscriptions, accountType: accountType)
        view?.display(subscriptionPlans: subscriptionPlans)
        
        view?.stopActivityIndicator()
    }
    
    func successed(offers: [OfferServiceResponse]) {
        let subscriptionPlans = interactor.convertToSubscriptionPlans(offers: offers, accountType: accountType)
        view?.display(subscriptionPlans: subscriptionPlans)
        view?.stopActivityIndicator()
    }
    
    func successed(offerApples: [OfferApple]) {
        let subscriptionPlans = interactor.convertToSubscriptionPlans(offerApples: offerApples)
        view?.display(subscriptionPlans: subscriptionPlans)
        view?.stopActivityIndicator()
    }
    
    func successed(offerApple: OfferApple) {
        view?.stopActivityIndicator()
    }
    
    func failedUsage(with error: ErrorResponse) {
        optInVC?.stopActivityIndicator()
        view?.stopActivityIndicator()
        view?.display(error: error)
    }
    
    func purchasesRestored(text: String) {
        
    }
}

// MARK: PackagesModuleInput
extension PackagesPresenter: PackagesModuleInput {

}
