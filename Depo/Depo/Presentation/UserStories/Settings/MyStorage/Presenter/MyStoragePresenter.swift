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
    private var optInVC: OptInController?
    var title: String
    
    private var userPhone = ""
    private var offerToBuy: PackageModelResponse?
    private var offerIndex: Int = 0
    private var referenceToken = ""
    
    private var quotaInfo: QuotaInfoResponse?
    private var percentage: CGFloat = 0
    
    private var allOffers: [SubscriptionPlanBaseResponse] = []
    private(set) var displayableOffers: [SubscriptionPlan] = []
    var availableOffers: [PackageOffer] = []

    init(title: String) {
        self.title = title
    }
    
    private func refreshPage() {
        allOffers = []
        displayableOffers = []
        availableOffers = []
        
        referenceToken = ""
        userPhone = ""
        offerToBuy = nil
        offerIndex = 0
        
        startActivity()
        interactor.getAllOffers()
        interactor.getAvailableOffers(with: accountType)
    }
    
    //MARK: - UtilityMethods
    private func displayOffers() {
        displayableOffers = interactor.convertToASubscriptionList(activeSubscriptionList: allOffers,
                                                                  accountType: accountType)
        if let index = displayableOffers.firstIndex(where: { $0.type == .free }) {
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
        interactor.getAccountTypePackages()
    }
    
    func viewWillAppear() {
        view?.startActivityIndicator()
        interactor.getUserAuthority()
        interactor.refreshActivePurchasesState(false)
    }
    
    func getAccountTypePackages() -> AccountType {
        return accountType
    }
    
    func didPressOn(plan: SubscriptionPlan, planIndex: Int) {
        let subscriptionModel = plan.model as? SubscriptionPlanBaseResponse
        
        interactor.trackPackageClick(plan: plan, planIndex: planIndex)
        interactor.trackNetmeraPackageCancelClick(type: subscriptionModel?.subscriptionPlanType?.type.rawValue ?? "",
                                                  packageName: subscriptionModel?.subscriptionPlanDisplayName ?? "")
        
        guard let model = subscriptionModel else {
            router?.showCancelOfferAlert(with: TextConstants.packageDefaultCancelText)
            return
        }

        guard let modelType = model.subscriptionPlanType else {
            if let key = model.subscriptionPlanLanguageKey {
                router?.showCancelOfferAlert(with: TextConstants.digicelCancelText(for: key))
                return
            } else {
                router?.showCancelOfferAlert(with: TextConstants.packageDefaultCancelText)
                return
            }
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
            } else if modelType.isSameAs(FeaturePackageType.allAccessFeature) {
                guard let accountType = self?.interactor.getAccountType(with: self?.accountType.rawValue ?? "", offers: [model]) else {
                    if let key = model.subscriptionPlanLanguageKey {
                        cancelText = TextConstants.digicelCancelText(for: key)
                    } else {
                        cancelText = TextConstants.offersAllCancel
                    }
                    self?.router?.showCancelOfferAlert(with: cancelText)
                    return
                }

                switch accountType {
                case .all:
                    cancelText = TextConstants.offersAllCancel
                case .cyprus:
                    cancelText = TextConstants.featureKKTCellCancelText
                case .ukranian:
                    cancelText = TextConstants.featureLifeCellCancelText
                case .life:
                    cancelText = TextConstants.featureLifeCancelText
                case .moldovian:
                    cancelText = TextConstants.featureMoldCellCancelText
                case .albanian:
                    cancelText = TextConstants.featureAlbanianCancelText
                case .turkcell:
                    cancelText = String(format: TextConstants.offersCancelTurkcell, model.subscriptionPlanName ?? "")
                case .FWI:
                    cancelText = TextConstants.featureDigicellCancelText
                case .jamaica:
                    cancelText = TextConstants.featureDigicellCancelText
                }
            } else {
                cancelText = String(format: type.cancelText, plan.name)
            }
            self?.router?.showCancelOfferAlert(with: cancelText)
        })
    }
    
    func didPressOnOffers(plan: SubscriptionPlan, planIndex: Int) {
        router.closePaymentPopUpController(closeAction: { [weak self] in
            self?.actionFor(plan: plan, planIndex: planIndex)
        })
    }
    
    private func actionFor(plan: SubscriptionPlan, planIndex: Int) {
        interactor.trackPackageClick(plan: plan, planIndex: planIndex)
        
        guard let model = plan.model as? PackageModelResponse else {
            assertionFailure()
            return
        }
        
        model.type?.purchaseActions(slcm: { [weak self] in
            self?.buy(offer: model, planIndex: planIndex)
        }, apple: { [weak self] in
            self?.view?.startActivityIndicator()
            self?.interactor.activate(offer: model, planIndex: planIndex)
        }, paycell: { [weak self] in
            guard let offerId = model.cpcmOfferId else {
                assertionFailure()
                return
            }
            self?.router.showPaycellProcess(with: offerId)
        }, notPaymentType: { [weak self] in
            assertionFailure("should not be another purchase options")
            let error = CustomErrors.serverError("This is not buyable offer type")
            self?.failed(with: error.localizedDescription)
        })
    }
    
    private func buy(offer: PackageModelResponse, planIndex: Int) {
        SingletonStorage.shared.getAccountInfoForUser(success: { [weak self] userInfoResponse in
            self?.userPhone = userInfoResponse.fullPhoneNumber
            self?.offerToBuy = offer
            self?.offerIndex = planIndex
            DispatchQueue.toMain {
                self?.view?.startActivityIndicator()
                self?.interactor.getToken(for: offer)
            }
        }, fail: { [weak self] failResponse in
            DispatchQueue.toMain {
                self?.view?.stopActivityIndicator()
                self?.failed(with: "An error occurred while getting account info.")
            }
        })
    }
    
    func restorePurchasesPressed() {
        interactor.restorePurchases()
    }
    
    func openTermsOfUseScreen() {
        router.openTermsOfUse()
    }
    
    func configureCard(_ card: PackageInfoView) {
        card.delegate = self
    }
    
    func showPremiumProcess() {
        router.showPremiumProcess()
    }
}

//MARK: - MyStorageInteractorOutput
extension MyStoragePresenter: MyStorageInteractorOutput {
    
    func purchaseCancelled() {
        view?.stopActivityIndicator()
    }
    
    func successedVerifyOffer() {
        optInVC?.stopLoading()
        optInVC?.resignFirstResponder()
        
        DispatchQueue.toMain {
            self.router.showSuccessPurchasedPopUp(with: self)
        }
    }
    
    func failedVerifyOffer() {
        optInVC?.stopLoading()
        optInVC?.clearCode()
        optInVC?.view.endEditing(true)
        
        if optInVC?.increaseNumberOfAttemps() == false {
            optInVC?.startEnterCode()
            optInVC?.showError(TextConstants.promocodeInvalid)
        }
    }
    
    
    func successedPackages(accountTypeString: String) {
        accountType = interactor.getAccountTypePackages(with: accountTypeString, offers: []) ?? .all
        view?.showInAppPolicy()
        interactor.getAvailableOffers(with: accountType)
    }

    func successedPackages(allOffers: [PackageModelResponse]) {
        accountType = interactor.getAccountTypePackages(with: accountType.rawValue, offers: allOffers)  ?? .all
        let offers = interactor.convertToSubscriptionPlan(offers: allOffers, accountType: accountType)
        availableOffers = filterPackagesByQuota(offers: offers)
        
        view?.stopActivityIndicator()
        view?.reloadData()
    }
    
    func filterPackagesByQuota(offers: [SubscriptionPlan]) -> [PackageOffer] {
        return Dictionary(grouping: offers, by: { $0.quota })
            .compactMap { PackageOffer(quotaNumber: $0.key, offers: $0.value) }
            .sorted(by: { $0.quotaNumber < $1.quotaNumber })
    }
    
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
    
    
    private func setMemoryPercentage() {
        if let used = quotaInfo?.bytesUsed, let total = quotaInfo?.bytes {
            percentage = 100 * CGFloat(used) / CGFloat(total)
        }
    }

    func successedGotUserAuthority() {
        view?.stopActivityIndicator()
    }
    
    
    func failedUsage(with error: ErrorResponse) {
        if let optInVC = optInVC {
            optInVC.stopLoading()
            optInVC.showError(error.description)
        } else {
            failed(with: error.description)
        }
    }
    
    func successed(allOffers: [PackageModelResponse]) {
        accountType = interactor.getAccountType(with: accountType.rawValue, offers: allOffers)  ?? .all
        let offers = interactor.convertToSubscriptionPlan(offers: allOffers, accountType: accountType)
        availableOffers = filterPackagesByQuota(offers: offers)
        
        view?.stopActivityIndicator()
        view?.reloadData()
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
        optInVC?.stopLoading()
        optInVC?.setupTimer(withRemainingTime: NumericConstants.verificationTimerLimit)
        optInVC?.startEnterCode()
        optInVC?.hiddenError()
        optInVC?.hideResendButton()
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

// MARK: - OptInControllerDelegate
extension MyStoragePresenter: OptInControllerDelegate {
    func optInResendPressed(_ optInVC: OptInController) {
        optInVC.startLoading()
        self.optInVC = optInVC
        if let offer = offerToBuy {
            interactor.getResendToken(for: offer)
        }
    }
    
    func optInReachedMaxAttempts(_ optInVC: OptInController) {
        optInVC.showResendButton()
        optInVC.dropTimer()
        optInVC.showError(TextConstants.promocodeBlocked)
    }
    
    func optInNavigationTitle() -> String {
        return TextConstants.optInNavigarionTitle
    }
    
    func optIn(_ optInVC: OptInController, didEnterCode code: String) {
        optInVC.startLoading()
        self.optInVC = optInVC
        interactor.verifyOffer(offerToBuy, planIndex: offerIndex, token: referenceToken, otp: code)
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

// MARK: PackagesModuleInput
extension MyStoragePresenter: MyStorageModuleInput {
    func startActivityIndicator() {
        
    }
    
    func stopActivityIndicator() {
        
    }
    

}
