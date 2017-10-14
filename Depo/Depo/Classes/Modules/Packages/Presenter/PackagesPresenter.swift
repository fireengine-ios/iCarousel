//
//  PackagesPackagesPresenter.swift
//  Depo
//
//  Created by Yaroslav Bondar on 20/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class PackagesPresenter {
    weak var view: PackagesViewInput!
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
                if plan.hasPrefix("lifebox") || plan.hasPrefix("kktcell") {
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
        interactor.activate(offer: offer)
    }
}

// MARK: PackagesInteractorOutput
extension PackagesPresenter: PackagesInteractorOutput {
    func successed(activeSubscriptions: [SubscriptionPlanBaseResponse]) {
        interactor.getAccountType()
        self.activeSubscriptions = activeSubscriptions
        let subscriptionPlans = interactor.convertToASubscriptionList(activeSubscriptionList: activeSubscriptions)
        view.display(subscriptionPlans: subscriptionPlans)
    }
    
    func successed(activateOffer: OfferServiceResponse) {
        print("Offer activated")
    }
    
    func successed(accountTypeString: String) {
        accountType = accountType(for: accountTypeString, subscriptionPlans: activeSubscriptions)
        switch accountType {
        case .turkcell:
            interactor.getOffers()
        case .subTurkcell:
            break
        case .all:
            interactor.getOfferApples()
        }
    }
    
    func successed(offers: [OfferServiceResponse]) {
        let subscriptionPlans = interactor.convertToSubscriptionPlans(offers: offers)
        view.display(subscriptionPlans: subscriptionPlans)
    }
    
    func successed(offerApples: [OfferApple]) {
        let subscriptionPlans = interactor.convertToSubscriptionPlans(offerApples: offerApples)
        view.display(subscriptionPlans: subscriptionPlans)
    }
    
    func successed(offerApple: OfferApple) {
        
    }
    
    func failedUsage(with error: ErrorResponse) {
        view.display(error: error)
    }
}

// MARK: PackagesModuleInput
extension PackagesPresenter: PackagesModuleInput {

}
