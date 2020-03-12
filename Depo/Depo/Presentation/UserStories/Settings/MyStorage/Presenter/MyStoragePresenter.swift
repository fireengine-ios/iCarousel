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
                
            case .moldovian, .turkcell, .life, .all, .albanian, .FWI, .jamaica:
                break
            }
        }
    }
    
    var title: String
    
    private var allOffers: [SubscriptionPlanBaseResponse] = []
    private(set) var displayableOffers: [SubscriptionPlan] = []

    init(title: String) {
        self.title = title
    }
    
    private func refreshPage() {
        allOffers = []
        displayableOffers = []
        
        startActivity()
        interactor.getAllOffers()
    }
    
    //MARK: - UtilityMethods
    private func displayOffers() {
        displayableOffers = interactor.convertToASubscriptionList(activeSubscriptionList: allOffers,
                                                                  accountType: accountType)
        if let index = displayableOffers.index(where: { $0.type == .free }) {
            displayableOffers.swapAt(0, index)
        }
        
        stopActivity()
        view?.reloadPackages()
    }
}

//MARK: - MyStorageViewOutput
extension MyStoragePresenter: MyStorageViewOutput {
    
    func viewDidLoad() {
        interactor.trackScreen()

        startActivity()
        interactor.getAccountType()
    }
    
    func didPressOn(plan: SubscriptionPlan, planIndex: Int) {
        interactor.trackPackageClick(plan: plan, planIndex: planIndex)
        
        guard let model = plan.model as? SubscriptionPlanBaseResponse, let modelType = model.subscriptionPlanType else {
            router?.showCancelOfferAlert(with: TextConstants.packageDefaultCancelText)
            return
        }
        
        modelType.cancellActions(slcm: { [weak self] type in
            let cancelText = String(format: type.cancelText, plan.getNameForSLCM())
            self?.router?.showCancelOfferAlert(with: cancelText)

        }, apple: { [weak self] _ in
            self?.router?.showCancelOfferApple()

        }, other: { [weak self] type in
            let cancelText: String
            if let key = model.subscriptionPlanLanguageKey {
                cancelText = TextConstants.digicelCancelText(for: key)
            } else {
                /// maybe needs "cancelText = TextConstants.offersAllCancel"
                cancelText = String(format: type.cancelText, plan.name)
            }
            self?.router?.showCancelOfferAlert(with: cancelText)

        })
    }
    
    func restorePurchasesPressed() {
        interactor.restorePurchases()
    }
    
    func configureCard(_ card: PackageInfoView) {
        card.delegate = self
    }
}

//MARK: - MyStorageInteractorOutput
extension MyStoragePresenter: MyStorageInteractorOutput {
    
    func successed(accountInfo: AccountInfoResponse) {
        ///https://jira.turkcell.com.tr/browse/FE-1642
        ///iOS: Packages - Adding refresh button on My Storage page for all type of users
        ///description in this task incorrent (title of this task correct)
        
//        if let accountTypeString = accountInfo.accountType {
//            accountType = interactor.getAccountType(with: accountTypeString, offers: allOffers) ?? .all
//        }
        
//        if accountType == .all {
        view?.showRestoreButton()
//        }
        
        interactor.getAllOffers()
    }
    
    func successed(allOffers: [SubscriptionPlanBaseResponse]) {
        self.allOffers = allOffers.filter {
            /// hide apple offers if apple server don't sent offer info
            if let appleId = $0.subscriptionPlanInAppPurchaseId, IAPManager.shared.product(for: appleId) == nil {
                return false
            } else {
                return true
            }
        }
        
        accountType = interactor.getAccountType(with: accountType.rawValue, offers: allOffers) ?? .all
        displayOffers()
    }
    
    func failed(with error: ErrorResponse) {
        stopActivity()
        router?.display(error: error.description)
    }
    
    func failed(with error: String) {
        stopActivity()
        router?.display(error: error)
    }
    
    func refreshPackages() {
        stopActivity()
        refreshPage()
    }
    
    func stopActivity() {
        view?.stopActivityIndicator()
    }
    
    func startActivity() {
        view?.startActivityIndicator()
    }
}

extension MyStoragePresenter: PackageInfoViewDelegate {

    func onSeeDetailsTap(with type: ControlPackageType) {
        switch type {
        case .usage, .myStorage, .myProfile:
            assertionFailure()
        case .accountType(let type):
            router.openLeavePremium(type: type.leavePremiumType)
        }
    }
}
