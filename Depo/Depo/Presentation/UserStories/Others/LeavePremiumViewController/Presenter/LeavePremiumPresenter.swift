//
//  LeavePremiumPresenter.swift
//  Depo
//
//  Created by Harbros 3 on 11/21/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

enum LeavePremiumType {
    case standard
    case middle
    case premium
    
    func listTypes(isTurkcell: Bool) -> [PremiumListType] {
        let types: [PremiumListType]
        switch self {
        case .standard:
            types = PremiumListType.standardTypes
        case .middle:
            types = PremiumListType.midTypes
        case .premium:
            types = PremiumListType.allTypes
        }
        
        return isTurkcell ? types : types.filter { $0 != .additionalData }
    }
    
    var title: String {
        switch self {
        case .standard:
            return TextConstants.lifeboxStandart
        case .middle:
            return TextConstants.lifeboxMiddle
        case .premium:
            return TextConstants.lifeboxPremium
        }
    }
    
    var topMessage: String {
        switch self {
        case .standard:
            return TextConstants.accountDetailStandartTitle
        case .middle:
            return TextConstants.accountDetailMiddleTitle
        case .premium:
            return TextConstants.leavePremiumPremiumDescription
        }
    }
    
    var detailMessage: String {
        switch self {
        case .standard:
            return TextConstants.accountDetailStandartDescription
        case .middle:
            return TextConstants.accountDetailMiddleDescription
        case .premium:
            return TextConstants.leavePremiumCancelDescription
        }
    }
}

final class LeavePremiumPresenter {
    
    weak var view: LeavePremiumViewInput!
    var interactor: LeavePremiumInteractorInput!
    var router: LeavePremiumRouterInput!
    
    var title: String
    var controllerType: LeavePremiumType
    var accountType: AccountType
    
    private var feature: SubscriptionPlanBaseResponse?
    private var price: String = TextConstants.free {
        didSet {
            displayPrice()
        }
    }
    
    private var cancelText: String? {
        guard let feature = feature, let featureType = feature.subscriptionPlanFeatureType else {
            return nil
        }
        
        if featureType == .allAccessFeature {
            switch interactor.getAccountType(with: accountType.rawValue, offers: [feature]) {
            case .all: return TextConstants.offersAllCancel
            case .cyprus: return TextConstants.featureKKTCellCancelText
            case .ukranian: return TextConstants.featureLifeCellCancelText
            case .life: return TextConstants.featureLifeCancelText
            case .moldovian: return TextConstants.featureMoldCellCancelText
            case .albanian: return TextConstants.featureAlbanianCancelText
            case .turkcell: return String(format: TextConstants.offersCancelTurkcell, feature.subscriptionPlanName ?? "")
            }
        } else {
            return featureType.cancelText
        }
    }
    
    init(type: LeavePremiumType) {
        self.title = type.title
        self.controllerType = type
        
        if let accountTypeString = SingletonStorage.shared.accountInfo?.accountType,
            let accountType = AccountType(rawValue: accountTypeString) {
            
            self.accountType = accountType
        } else {
            self.accountType = .all
        }
    }
    
    // MARK: Utility methods
    private func displayPrice() {
        view?.stopActivityIndicator()
        
        let isNeedHideButton = price == TextConstants.free
        view?.display(price: price, hideLeaveButton: isNeedHideButton)
    }
}

// MARK: - LeavePremiumViewOutput
extension LeavePremiumPresenter: LeavePremiumViewOutput {
    
    func onViewDidLoad(with premiumView: LeavePremiumView) {
        premiumView.delegate = self
        
        if controllerType != .standard {
            view?.startActivityIndicator()
            interactor.getActiveSubscription()
        }
    }
    
}

// MARK: - LeavePremiumInteractorOtuput
extension LeavePremiumPresenter: LeavePremiumInteractorOutput {
    func didLoadActiveSubscriptions(_ offers: [SubscriptionPlanBaseResponse]) {
        let type: AuthorityType = controllerType == .premium ? .premiumUser : .middleUser
        feature = offers.first(where: { offer in
            return offer.subscriptionPlanAuthorities?.contains(where: { $0.authorityType == type }) ?? false
        })
        
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
    
    func didLoadInfoFromApple() {
        guard let offer = feature else {
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
