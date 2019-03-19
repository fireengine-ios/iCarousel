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
    
    var availableOffers: [SubscriptionPlan] = []
    
    private var accountType = AccountType.all

    private var referenceToken = ""
    private var userPhone = ""
    private var offerToBuy: PackageModelResponse?
    private var offerIndex: Int = 0
    private var optInVC: OptInController?
    private var storageCapacity: Int64 = 0
    private var storageUsage: UsageResponse?
    
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
}

// MARK: PackagesViewOutput
extension PackagesPresenter: PackagesViewOutput {
    func getAccountType() -> AccountType {
        return accountType
    }

    func getStorageCapacity() -> Int64 {
        return storageCapacity
    }
    
    func submit(promocode: String) {
        interactor.submit(promocode: promocode)
    }
    
    func viewIsReady() {
        interactor.trackScreen()
        
        view?.startActivityIndicator()
        interactor.getAccountType()
        
        view?.startActivityIndicator()
        interactor.getStorageCapacity()
    }
    
    func viewWillAppear() {
        view?.startActivityIndicator()
        interactor.getUserAuthority()
    }
    
    func didPressOn(plan: SubscriptionPlan, planIndex: Int) {

        interactor.trackPackageClick(plan: plan, planIndex: planIndex)
        guard let model = plan.model as? PackageModelResponse else {
            return
        }
        switch model.type {
        case .SLCM?:
            let title = String(format: TextConstants.turkcellPurchasePopupTitle, model.quota?.bytesString ?? "")

            let price = interactor.getPriceInfo(for: model, accountType: accountType)
            view?.showActivateOfferAlert(with: title, price: price, for: model, planIndex: planIndex)
        case .apple?:
            view?.startActivityIndicator()
            interactor.activate(offer: model, planIndex: planIndex)
        default:
            let error = CustomErrors.serverError("This is not buyable offer type")
            failed(with: error.localizedDescription)
         }
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
        optInVC.startActivityIndicator()
        self.optInVC = optInVC
        if let offer = offerToBuy {
            interactor.getResendToken(for: offer)
        }
    }
    
    func optInReachedMaxAttempts(_ optInVC: OptInController) {
        optInVC.showResendButton()
        optInVC.dropTimer()
        view?.display(error: ErrorResponse.string(TextConstants.promocodeBlocked))
    }
    
    func optInNavigationTitle() -> String {
        return TextConstants.optInNavigarionTitle
    }
    
    func optIn(_ optInVC: OptInController, didEnterCode code: String) {
        optInVC.startActivityIndicator()
        self.optInVC = optInVC
        interactor.verifyOffer(offerToBuy, planIndex: offerIndex, token: referenceToken, otp: code)
    }
}

// MARK: PackagesInteractorOutput
extension PackagesPresenter: PackagesInteractorOutput {
    func successedPromocode() {
        MenloworksAppEvents.onPromocodeActivated()
        view?.successedPromocode()
    }
    
    func successedVerifyOffer() {
        optInVC?.stopActivityIndicator()
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
        optInVC?.stopActivityIndicator()
        optInVC?.setupTimer(withRemainingTime: NumericConstants.vereficationTimerLimit)
        optInVC?.startEnterCode()
        optInVC?.hideResendButton()
    }
    
    func successed(accountTypeString: String) {
        accountType = interactor.getAccountType(with: accountTypeString, offers: [])
        
        if accountType != .turkcell {
            view?.showInAppPolicy()
        }
        
        interactor.getAvailableOffers(with: accountType)
    }
    
    func successed(usage: UsageResponse) {
        view?.stopActivityIndicator()
        storageUsage = usage
        if let quotaBytes = usage.quotaBytes {
            storageCapacity = quotaBytes
            view?.setupStackView(with: quotaBytes)
        }
    }
    
    func successed(allOffers: [PackageModelResponse]) {
        accountType = interactor.getAccountType(with: accountType.rawValue, offers: allOffers)
        
        let offers = interactor.convertToSubscriptionPlan(offers: allOffers, accountType: accountType)
        availableOffers = offers.filter({
            guard let model = $0.model as? PackageModelResponse, let type = model.type else { return false }
            
            ///show only offers with type slcm and apple(if apple sent offer info)
            switch type {
            case .SLCM: return true
            case .apple: return IAPManager.shared.product(for: model.inAppPurchaseId ?? "") != nil
            default: return false
            }
        })
        view?.stopActivityIndicator()
        view?.reloadData()
    }

    func successedGotUserAuthority() {
        view?.stopActivityIndicator()
        view?.setupStackView(with: storageCapacity)
    }
    
    func failedPromocode(with errorString: String) {
        view?.show(promocodeError: errorString)
    }
    
    func failedVerifyOffer() {
        optInVC?.stopActivityIndicator()
        optInVC?.clearCode()
        optInVC?.view.endEditing(true)
        
        if optInVC?.increaseNumberOfAttemps() == false {
            let vc = PopUpController.with(title: TextConstants.checkPhoneAlertTitle, message: TextConstants.promocodeInvalid, image: .error, buttonTitle: TextConstants.ok)
            optInVC?.present(vc, animated: false, completion: nil)
        }
    }
    
    func failedUsage(with error: ErrorResponse) {
        view?.stopActivityIndicator()
        view?.display(error: error)
    }

    func failed(with errorMessage: String) {
        view?.stopActivityIndicator()
        view?.display(errorMessage: errorMessage)
    }
    
    func purchasesRestored(text: String) {
        
    }
    
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
        case .myStorage:
            router.openMyStorage(storageUsage: storageUsage)
        case .premiumUser, .standardUser, .middleUser:
            let leavePremiumType: LeavePremiumType
            if type == .standardUser {
                leavePremiumType = .standard
            } else if type == .middleUser {
                leavePremiumType = .middle
            } else {
                leavePremiumType = .premium
            }
            router.openLeavePremium(type: leavePremiumType)
        case .premiumBanner:
            break
        }
    }
}
