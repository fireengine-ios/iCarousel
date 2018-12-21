//
//  LeavePremiumPresenter.swift
//  Depo
//
//  Created by Harbros 3 on 11/21/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class LeavePremiumPresenter {
    
    weak var view: LeavePremiumViewInput!
    var interactor: LeavePremiumInteractorInput!
    var router: LeavePremiumRouterInput!
    
    var title: String

    private var feature: SubscriptionPlanBaseResponse?
    private var accountType: AccountType?
    private var price: String = TextConstants.free {
        didSet {
            displayPrice()
        }
    }
    
    private var cancelText: String? {
        guard let featureType = feature?.subscriptionPlanFeatureType, let accountType = accountType else {
            return nil
        }
        
        if featureType == .allAccessFeature {
            switch accountType {
            case .all: return TextConstants.offersAllCancel
            case .cyprus: return TextConstants.offersCancelCyprus
            case .ukranian: return TextConstants.offersCancelUkranian
            case .life: return TextConstants.offersCancelLife
            case .moldovian: return TextConstants.offersCancelMoldcell
            case .turkcell: return TextConstants.offersCancelTurkcell
            }
        }
        
        return featureType.cancelText
    }
    
    init(title: String) {
        self.title = title
    }
    
    // MARK: Utility methods
    private func displayPrice() {
        view?.stopActivityIndicator()
        view?.display(price: price)
    }
    
    private func getAccountType(for accountType: String, subscription: SubscriptionPlanBaseResponse?) -> AccountType {
        var type: AccountType = .all
        if accountType == "TURKCELL" {
            type = .turkcell
        } else if let role = subscription?.subscriptionPlanRole?.lowercased() {
            if role.contains("lifecell") {
                type = .ukranian
            } else if role.contains("kktcell") {
                type = .cyprus
            } else if role.contains("moldcell") {
                type = .moldovian
            } else if role.contains("life") {
                type = .life
            }
        }
        return type
    }
}

// MARK: - LeavePremiumViewOutput
extension LeavePremiumPresenter: LeavePremiumViewOutput {
    
    func onViewDidLoad(with premiumView: LeavePremiumView) {
        premiumView.delegate = self
        
        view?.startActivityIndicator()
        interactor.getActiveSubscription()
    }
    
}

// MARK: - LeavePremiumInteractorOtuput
extension LeavePremiumPresenter: LeavePremiumInteractorOutput {
    func didLoadAccountType(accountTypeString: String) {
        let accountType = getAccountType(for: accountTypeString,subscription: feature)
        self.accountType = accountType
        
        guard let feature = feature, let featureType = feature.subscriptionPlanFeatureType else {
            let error = CustomErrors.text("An error occurred while getting feature type from offer.")
            didErrorMessage(with: error.localizedDescription)
            return
        }
        
        if featureType == .appleFeature {
            interactor.getAppleInfo(for: feature)
        } else {
            price = interactor.getPrice(for: feature, accountType: accountType)
        }
    }
    
    func didLoadActiveSubscriptions(_ offers: [SubscriptionPlanBaseResponse]) {
        offers.forEach { offer in
            if let authorities = offer.subscriptionPlanAuthorities, feature == nil {
                if authorities.contains(where: { $0.authorityType == .premiumUser }) {
                    feature = offer
                    print("iteration breaked")
                }
                print("iteration continue")
            }
        }
        
        interactor.getAccountType()
    }
    
    func didLoadInfoFromApple() {
        guard let offer = feature, let accountType = accountType else {
            let error = CustomErrors.serverError("An error occurred while getting offer.")
            didErrorMessage(with: error.localizedDescription)
            return
        }
        price = interactor.getPrice(for: offer, accountType: accountType)
    }
    
    func didErrorMessage(with text: String) {
        view?.stopActivityIndicator()
        router.showError(with: text)
    }
}

// MARK: - LeavePremiumViewDelegate
extension LeavePremiumPresenter: LeavePremiumViewDelegate {
    
    func onLeavePremiumTap() {
        guard let cancelText = cancelText else {
            let error = CustomErrors.text("An error occurred while preparing info for cancel description alert.")
            didErrorMessage(with: error.localizedDescription)
            return
        }
        
        router.showAlert(with: cancelText)
    }
}
