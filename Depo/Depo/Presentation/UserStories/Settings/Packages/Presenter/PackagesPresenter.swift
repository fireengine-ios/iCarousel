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
    
    var availableOffers: [PackageOffer] = []
    
    private var quotaInfo: QuotaInfoResponse?

    private var accountType = AccountType.all

    private var referenceToken = ""
    private var userPhone = ""
    private var offerToBuy: PackageModelResponse?
    private var offerIndex: Int = 0
    private var optInVC: OptInController?
    private var percentage: CGFloat = 0
    
    private func refreshPage() {
        availableOffers = []
        referenceToken = ""
        userPhone = ""
        offerToBuy = nil
        offerIndex = 0
        optInVC = nil
        
        view?.startActivityIndicator()
        interactor.getAvailableOffers(with: accountType)
    }
    
    func tuneUpQuota(quotaInfo: QuotaInfoResponse?) {
        if let quota = quotaInfo{
            self.quotaInfo = quota
        }
    }
}

// MARK: PackagesViewOutput
extension PackagesPresenter: PackagesViewOutput {
    
    func getAccountType() -> AccountType {
        return accountType
    }
    
    func submit(promocode: String) {
        interactor.submit(promocode: promocode)
    }
    
    func viewIsReady() {
        interactor.trackScreen()
        
        view?.startActivityIndicator()
        interactor.getQuotaInfo()
        
        view?.startActivityIndicator()
        interactor.getAccountType()
    }
    
    func viewWillAppear() {
        view?.startActivityIndicator()
        interactor.getUserAuthority()
        interactor.refreshActivePurchasesState(false)
    }
    
    func didPressOn(plan: SubscriptionPlan, planIndex: Int) {
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
    
    func buy(offer: PackageModelResponse, planIndex: Int) {
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

}

// MARK: - OptInControllerDelegate
extension PackagesPresenter: OptInControllerDelegate {
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

// MARK: PackagesInteractorOutput
extension PackagesPresenter: PackagesInteractorOutput {
  
    func setQuotaInfo(quotoInfo: QuotaInfoResponse) {
        view?.stopActivityIndicator()

        self.quotaInfo = quotoInfo
        setMemoryPercentage()
    }
    
    func successedPromocode() {
        view?.successedPromocode()
    }
    
    func successedVerifyOffer() {
        optInVC?.stopLoading()
        optInVC?.resignFirstResponder()
        
        DispatchQueue.toMain {
            self.router.showSuccessPurchasedPopUp(with: self)
        }
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
    
    func successed(accountTypeString: String) {
        accountType = interactor.getAccountType(with: accountTypeString, offers: []) ?? .all
        view?.showInAppPolicy()
        interactor.getAvailableOffers(with: accountType)
    }
    
    func setMemoryPercentage() {
        if let used = quotaInfo?.bytesUsed, let total = quotaInfo?.bytes {
            percentage = 100 * CGFloat(used) / CGFloat(total)
            view?.setupStackView(with: percentage)
        }
    }
    
    func successed(allOffers: [PackageModelResponse]) {
        accountType = interactor.getAccountType(with: accountType.rawValue, offers: allOffers)  ?? .all
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

    func successedGotUserAuthority() {
        view?.stopActivityIndicator()
        view?.setupStackView(with: percentage)
    }
    
    func failedPromocode(with errorString: String) {
        view?.show(promocodeError: errorString)
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
    
    func failedUsage(with error: ErrorResponse) {
        if let optInVC = optInVC {
            optInVC.stopLoading()
            optInVC.showError(error.description)
        } else {
            failed(with: error.description)
        }
    }

    func failed(with errorMessage: String) {
        view?.stopActivityIndicator()
        view?.display(errorMessage: errorMessage)
    }
    
    func purchasesRestored(text: String) { }
    
    func refreshPackages() {
        view?.stopActivityIndicator()
        refreshPage()
    }
}

// MARK: PackagesModuleInput
extension PackagesPresenter: PackagesModuleInput {

}

// MARK: PackageInfoViewDelegate
extension PackagesPresenter: PackageInfoViewDelegate {

    func onSeeDetailsTap(with type: ControlPackageType) {
        switch type {
        case .usage:
            router.openUsage()
        case .myStorage:
            let usage = UsageResponse()
            usage.usedBytes = quotaInfo?.bytesUsed
            usage.quotaBytes = quotaInfo?.bytes
            router.openMyStorage(usageStorage: usage)
        case .myProfile:
            guard let userInfo = SingletonStorage.shared.accountInfo else {
                let error = CustomErrors.text("Unexpected found nil while getting user info. Refresh page may solve this problem.")
                failed(with: error.localizedDescription)
                return
            }
            
            let isTurkcell = SingletonStorage.shared.isTurkcellUser
            router.openUserProfile(userInfo: userInfo, isTurkcellUser: isTurkcell)
            break
        case .accountType:
            assertionFailure()
        }
    }
}
