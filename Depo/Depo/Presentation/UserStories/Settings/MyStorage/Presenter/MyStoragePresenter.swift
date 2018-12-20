//
//  MyStoragePresenter.swift
//  Depo
//
//  Created by Raman Harhun on 11/27/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class MyStoragePresenter {
    weak var view: MyStorageViewInput?
    var interactor: MyStorageInteractorInput!
    var router: MyStorageRouterInput!
    
    var usage: UsageResponse!
    var accountType: AccountType = .all
    var displayableOffers: [SubscriptionPlan] = []
    
    var title: String
    
    private var allOffers: [SubscriptionPlanBaseResponse] = []
    
    init(title: String) {
        self.title = title
    }
    
    //MARK: - UtilityMethods
    private func getAccountType(for accountType: String, subscriptions: [SubscriptionPlanBaseResponse]) -> AccountType {
        if accountType == "TURKCELL" {
            return .turkcell
        } else {
            let plans = subscriptions.flatMap { return $0.subscriptionPlanRole }
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
    
    private func calculateProgress() {
        let usedStorageSize = usage.usedBytes ?? 0
        let fullStorageSize = usage.quotaBytes ?? 0
        
        let leftStorageSize = fullStorageSize - usedStorageSize
        
        view?.configureProgress(with: fullStorageSize, left: leftStorageSize)
    }
    
    private func displayOffers() {
        displayableOffers = interactor.convertToASubscriptionList(activeSubscriptionList: allOffers, accountType: accountType)
        if let index = displayableOffers.index(where: { $0.type == .free }) {
            displayableOffers.swapAt(0, index)
        }
        
        view?.stopActivityIndicator()
        view?.reloadCollectionView()
    }
}

//MARK: - MyStorageViewOutput
extension MyStoragePresenter: MyStorageViewOutput {
    func viewDidLoad() {
        view?.startActivityIndicator()
        interactor.getAllOffers()
        interactor.getUsage()

        if usage != nil {
            calculateProgress()
        }
    }
    
    func didPressOn(plan: SubscriptionPlan, planIndex: Int) {
        interactor.trackPackageClick(plan: plan, planIndex: planIndex)
        guard let model = plan.model as? SubscriptionPlanBaseResponse, let type =  model.subscriptionPlanType else {
            router?.showCancelOfferAlert(with: TextConstants.packageDefaultCancelText)
            return
        }
        if type != .apple {
            let cancelText = String(format: type.cancelText, plan.name)
            router?.showCancelOfferAlert(with: cancelText)
        } else {
            router?.showCancelOfferApple()
        }
    }
}

//MARK: - MyStorageInteractorOutput
extension MyStoragePresenter: MyStorageInteractorOutput {
    
    func successed(usage: UsageResponse) {
        self.usage = usage
        calculateProgress()
    }
    
    func successed(accountInfo: AccountInfoResponse) {
        if let accountType = accountInfo.accountType {
            self.accountType = getAccountType(for: accountType, subscriptions: allOffers)
        }
        displayOffers()
    }
    
    func successed(allOffers: [SubscriptionPlanBaseResponse]) {
        self.allOffers = allOffers.filter {
            //show only non-feature offers
            if $0.subscriptionPlanType == nil {
                 return false
            }
            
            //hide apple offers if apple server don't sent offer info
            if let appleId = $0.subscriptionPlanInAppPurchaseId, IAPManager.shared.product(for: appleId) == nil {
                return false
            }
            
            return true
        }
        interactor.getAccountType()
    }
    
    func configureAppleOffers() {
        interactor.getAccountType()
    }
    
    func failed(with error: ErrorResponse) {
        view?.stopActivityIndicator()
        router?.display(error: error.localizedDescription)
    }
    
    func failed(with error: String) {
        view?.stopActivityIndicator()
        router?.display(error: error)
    }
}
