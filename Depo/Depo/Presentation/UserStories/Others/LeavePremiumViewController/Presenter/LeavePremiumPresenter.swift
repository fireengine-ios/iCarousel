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
    var activeSubscriptions: [SubscriptionPlanBaseResponse]
    
    private let authorityStorage: AuthorityStorage = factory.resolve()
    
    init(title: String, activeSubscriptions: [SubscriptionPlanBaseResponse]) {
        self.title = title
        self.activeSubscriptions = activeSubscriptions
    }
    
    private func getAccountType(for accountType: String, subscriptionPlans: [SubscriptionPlanBaseResponse]) -> AccountType {
        if accountType == "TURKCELL" {
            return .turkcell
        } else {
            let plans = subscriptionPlans.flatMap { $0.subscriptionPlanRole }
            for plan in plans {
                if plan.hasPrefix("lifebox") {
                    return .ukranian
                } else if plan.hasPrefix("kktcell") {
                    return .cyprus
                } else if plan.hasPrefix("moldcell") {
                    return .moldovian
                } else if plan.hasPrefix("life") {
                    return .life
                }
            }
            return .all
        }
    }
    
}

// MARK: - LeavePremiumViewOutput
extension LeavePremiumPresenter: LeavePremiumViewOutput {
    
    func onViewDidLoad(with premiumView: LeavePremiumView) {
        premiumView.delegate = self
    }
    
}

// MARK: - LeavePremiumInteractorOtuput
extension LeavePremiumPresenter: LeavePremiumInteractorOutput {
    func didLoadAccountType(accountTypeString: String) {
        authorityStorage.refrashStatus(premium: false, dublicates: false, faces: false)
        
        let accountType = getAccountType(for: accountTypeString, subscriptionPlans: activeSubscriptions)
        if accountType != .turkcell {
            router.showAlert(with: TextConstants.loremNonTurkcell)
        } else {
            router.showAlert(with: TextConstants.loremTurkcell)
        }
    }
}

// MARK: - LeavePremiumViewDelegate
extension LeavePremiumPresenter: LeavePremiumViewDelegate {
    
    func onLeavePremiumTap() {
        interactor.getAccountType()
    }
    
}
