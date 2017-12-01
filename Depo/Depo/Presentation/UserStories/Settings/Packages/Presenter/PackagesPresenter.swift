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
    var accountType = AccountType.all
    
    private func accountType(for accountType: String, subscriptionPlans: [SubscriptionPlanBaseResponse]) -> AccountType {
        if accountType == "TURKCELL" {
            return AccountType.turkcell
        } else {
            let plans = subscriptionPlans.flatMap { $0.subscriptionPlanRole }
            var isSubTur = false
            for plan in plans {
                if plan.hasPrefix("lifebox") || plan.hasPrefix("kktcell") || plan.hasPrefix("moldcell") {
                    isSubTur = true
                    break
                }
            }
            if isSubTur {
                return AccountType.subTurkcell
            } else {
                return AccountType.all
            }
        }
    }
    
    var referenceToken = ""
    var userPhone = ""
    var offerToBuy: OfferServiceResponse?
    var optInVC: OptInController?
}

// MARK: PackagesViewOutput
extension PackagesPresenter: PackagesViewOutput {
    func viewIsReady() {
        interactor.getActiveSubscriptions()
    }
    
    func didPressOn(plan: SubscriptionPlan) {
        switch accountType {
        case .turkcell:
            if let offer = plan.model as? OfferServiceResponse { /// from active subscription list
                view?.showActivateOfferAlert(for: offer)
            } else {
                view?.showCancelOfferAlert(for: accountType)
            }
        case .subTurkcell:
            view?.showCancelOfferAlert(for: accountType)
        case .all:
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
        },  fail: { [weak self] failResponse in
            DispatchQueue.main.async {
                self?.view?.stopActivityIndicator()
            }
        })
    }
}

// MARK: - OptInControllerDelegate
extension PackagesPresenter: OptInControllerDelegate {
    func optInResendPressed(_ optInVC: OptInController) {
        self.optInVC = optInVC
        if let offer = offerToBuy {
            interactor.getResendToken(for: offer)
        }
    }
    
    func optInReachedMaxAttempts(_ optInVC: OptInController) {
        optInVC.showResendButton()
        optInVC.dropTimer()
    }
    
    func optInNavigationTitle() -> String {
        return TextConstants.optInNavigarionTitle
    }
    
    func optIn(_ optInVC: OptInController, didEnterCode code: String) {
        self.optInVC = optInVC
        interactor.verifyOffer(token: referenceToken, otp: code)
    }
}

// MARK: PackagesInteractorOutput
extension PackagesPresenter: PackagesInteractorOutput {
    
    func successedJobExists() {
        interactor.getOffers()
    }
    
    func failedVerifyOffer() {
        optInVC?.increaseNumberOfAttemps()
        optInVC?.clearCode()
        optInVC?.view.endEditing(true)
        CustomPopUp.sharedInstance.showCustomInfoAlert(withTitle: TextConstants.checkPhoneAlertTitle, withText: TextConstants.phoneVereficationNonValidCodeErrorText, okButtonText: TextConstants.ok)
    }
    
    func successedVerifyOffer() {
        optInVC?.resignFirstResponder()
        RouterVC().popViewController()
    }
    
    func successed(activeSubscriptions: [SubscriptionPlanBaseResponse]) {
        interactor.getAccountType()
        self.activeSubscriptions = activeSubscriptions
        let subscriptionPlans = interactor.convertToASubscriptionList(activeSubscriptionList: activeSubscriptions)
        view?.display(subscriptionPlans: subscriptionPlans)
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
        optInVC?.setupTimer(withRemainingTime: NumericConstants.vereficationTimerLimit)
        optInVC?.startEnterCode()
        optInVC?.hideResendButton()
    }
    
    func successed(accountTypeString: String) {
        accountType = accountType(for: accountTypeString, subscriptionPlans: activeSubscriptions)
        switch accountType {
        case .turkcell:
            interactor.checkJobExists()
        case .subTurkcell:
            break
        case .all:
            interactor.getOfferApples()
        }
    }
    
    func successed(offers: [OfferServiceResponse]) {
        let subscriptionPlans = interactor.convertToSubscriptionPlans(offers: offers)
        view?.display(subscriptionPlans: subscriptionPlans)
    }
    
    func successed(offerApples: [OfferApple]) {
        let subscriptionPlans = interactor.convertToSubscriptionPlans(offerApples: offerApples)
        view?.display(subscriptionPlans: subscriptionPlans)
    }
    
    func successed(offerApple: OfferApple) {
        
    }
    
    func failedUsage(with error: ErrorResponse) {
        view?.stopActivityIndicator()
        view?.display(error: error)
    }
}

// MARK: PackagesModuleInput
extension PackagesPresenter: PackagesModuleInput {

}
