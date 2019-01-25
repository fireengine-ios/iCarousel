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
        guard let feature = feature, let featureType = feature.subscriptionPlanFeatureType else {
            return nil
        }
        
        let cancelText: String
        if let accountType = accountType, featureType == .allAccessFeature {
            switch interactor.getAccountType(with: accountType.rawValue, offers: [feature]) {
            case .all: return TextConstants.offersAllCancel
            case .cyprus: return TextConstants.featureKKTCellCancelText
            case .ukranian: return TextConstants.featureLifeCellCancelText
            case .life: return TextConstants.featureLifeCancelText
            case .moldovian: return TextConstants.featureMoldCellCancelText
            case .albanian: return TextConstants.featureMoldCellCancelText
            case .turkcell: return String(format: TextConstants.offersCancelTurkcell, feature.subscriptionPlanName ?? "")
            }
        } else {
            return featureType.cancelText
        }
    }
    
    init(title: String) {
        self.title = title
    }
    
    // MARK: Utility methods
    private func displayPrice() {
        view?.stopActivityIndicator()
        view?.display(price: price)
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
        let accountType = interactor.getAccountType(with: accountTypeString, offers: [feature])
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
        feature = offers.first(where: { offer in
            return offer.subscriptionPlanAuthorities?.contains(where: { $0.authorityType == .premiumUser }) ?? false
        })
        
        guard let feature = feature else {
            let error = CustomErrors.text("No feature pack with premium authority type.")
            didErrorMessage(with: error.localizedDescription)
            return
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
