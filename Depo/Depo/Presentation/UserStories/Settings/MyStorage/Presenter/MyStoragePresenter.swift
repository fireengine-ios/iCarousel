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
    var accountType: AccountType = .all {
        didSet {
            switch accountType {
            case .ukranian:
                router.showSubTurkcellOpenAlert(with: TextConstants.offersActivateUkranian)
            case .cyprus:
                router.showSubTurkcellOpenAlert(with: TextConstants.offersActivateCyprus)
            case .moldovian, .turkcell, .life, .all, .albanian, .FWI, .jamaica: break
            }
        }
    }
    
    var title: String
    
    private var allOffers: [SubscriptionPlanBaseResponse] = []
    var displayableOffers: [PackageOffer] = []

    init(title: String) {
        self.title = title
    }
    
    private func refreshPage() {
        allOffers = []
        displayableOffers = []
        
        view?.startActivityIndicator()
        interactor.getAllOffers()
    }
    
    //MARK: - UtilityMethods
    private func calculateProgress() {
        let usedStorageSize = usage.usedBytes ?? 0
        let fullStorageSize = usage.quotaBytes ?? 0
        
        view?.configureProgress(with: fullStorageSize, used: usedStorageSize)
    }
    
    private func displayOffers() {
        let offers = interactor.convertToASubscriptionList(activeSubscriptionList: allOffers, accountType: accountType)
        
        displayableOffers = filterPackagesByQuota(offers: offers)
        
        if let index = displayableOffers.first?.offers.index(where: { $0.type == .free }) {
            displayableOffers.swapAt(0, index)
        }
        
        view?.stopActivityIndicator()
        view?.reloadCollectionView()
    }
    
    func filterPackagesByQuota(offers: [SubscriptionPlan]) -> [PackageOffer] {
        return Dictionary(grouping: offers, by: { $0.quota })
            .compactMap { dict in
                return PackageOffer(quotaNumber: dict.key, offers: dict.value)
            }.sorted(by: { $0.quotaNumber < $1.quotaNumber })
    }
}

//MARK: - MyStorageViewOutput
extension MyStoragePresenter: MyStorageViewOutput {
    
    func viewDidLoad() {
        view?.startActivityIndicator()
        calculateProgress()
        interactor.trackScreen()
        interactor.getAccountType()
        interactor.getUsage()
    }
    
    func didPressOn(plan: SubscriptionPlan, planIndex: Int) {
        interactor.trackPackageClick(plan: plan, planIndex: planIndex)
        
        guard let model = plan.model as? SubscriptionPlanBaseResponse else {
            router?.showCancelOfferAlert(with: TextConstants.packageDefaultCancelText)
            return
        }
        
        if let type = model.subscriptionPlanType {
            switch type {
            case .apple:
                router?.showCancelOfferApple()
                
            case .SLCM:
                let cancelText = String(format: type.cancelText, plan.getNameForSLCM())
                router?.showCancelOfferAlert(with: cancelText)
                
            default:
                let cancelText: String
                if let key = model.subscriptionPlanLanguageKey {
                    cancelText = TextConstants.digicelCancelText(for: key)
                } else {
                    // TODO: can we set "cancelText = TextConstants.offersAllCancel" ?
                    cancelText = String(format: type.cancelText, plan.name)
                }
                
                router?.showCancelOfferAlert(with: cancelText)
            }
            
        } else {
            
            let cancelText: String
            if let key = model.subscriptionPlanLanguageKey {
                cancelText = TextConstants.digicelCancelText(for: key)
            } else {
                cancelText = TextConstants.offersAllCancel
            }
            
            router?.showCancelOfferAlert(with: cancelText)
        }
        
    }
    
    func restorePurchasesPressed() {
        interactor.restorePurchases()
    }
}

//MARK: - MyStorageInteractorOutput
extension MyStoragePresenter: MyStorageInteractorOutput {
    
    func successed(usage: UsageResponse) {
        self.usage = usage
        calculateProgress()
    }
    
    func successed(accountInfo: AccountInfoResponse) {
        if let accountTypeString = accountInfo.accountType {
            accountType = interactor.getAccountType(with: accountTypeString, offers: allOffers)
        }
        
        if accountType == .all {
            view?.showRestoreButton()
        }
        
        interactor.getAllOffers()
    }
    
    func successed(allOffers: [SubscriptionPlanBaseResponse]) {
        self.allOffers = allOffers.filter {
            /// show only non-feature offers
            if $0.subscriptionPlanType == nil {
                 return false
            }
            
            /// hide apple offers if apple server don't sent offer info
            if let appleId = $0.subscriptionPlanInAppPurchaseId, IAPManager.shared.product(for: appleId) == nil {
                return false
            }
            
            return true
        }
        
        accountType = interactor.getAccountType(with: accountType.rawValue, offers: allOffers)
        displayOffers()
    }
    
    func failed(with error: ErrorResponse) {
        view?.stopActivityIndicator()
        router?.display(error: error.description)
    }
    
    func failed(with error: String) {
        view?.stopActivityIndicator()
        router?.display(error: error)
    }
    
    func refreshPackages() {
        view?.stopActivityIndicator()
        refreshPage()
    }
}
