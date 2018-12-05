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

    private let group = DispatchGroup()
    
    private func getAccountType(for accountType: String) -> AccountType {
        if accountType == "TURKCELL" {
            return .turkcell
        } else {
            return .all
        }
    }
    
    private func refreshPage() {
        view?.startActivityIndicator()
        
        availableOffers = []
        referenceToken = ""
        userPhone = ""
        offerToBuy = nil
        offerIndex = 0
        optInVC = nil
        
        group.enter()
        interactor.getAvailableOffers(group: group)
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
        interactor.getAccountType(group: group)
        interactor.getStorageCapacity(group: group)
    }
    
    func viewWillAppear() {
        view?.startActivityIndicator()
        interactor.getUserAuthority(group: group)
        
        group.notify(queue: DispatchQueue.main) {
            self.view?.stopActivityIndicator()
        }
    }
    
    func didPressOn(plan: SubscriptionPlan, planIndex: Int) {

        interactor.trackPackageClick(plan: plan, planIndex: planIndex)
        guard let model = plan.model as? PackageModelResponse else { return }
        switch model.type {
        case .SLCM?:
            view?.showActivateOfferAlert(for: model, planIndex: planIndex)
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

    func configureViews(_ views: [PackageInfoView]) {
        for view in views {
            view.delegate = self
        }
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
        RouterVC().popViewController()
        
        refreshPage()
        
        /// to wait popViewController animation
        DispatchQueue.main.asyncAfter(deadline: .now() + NumericConstants.animationDuration) { 
            let popupVC = PopUpController.with(title: TextConstants.success,
                                               message: TextConstants.successfullyPurchased,
                                               image: .success,
                                               buttonTitle: TextConstants.ok)
            RouterVC().presentViewController(controller: popupVC)
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
        accountType = getAccountType(for: accountTypeString)
        interactor.getAvailableOffers(group: group)
    }
    
    func successed(usage: UsageResponse) {
        storageUsage = usage
        if let quotaBytes = usage.quotaBytes {
            storageCapacity = quotaBytes
            view?.setupStackView(with: quotaBytes)
        }
    }
    
    func successed(allOffers: [PackageModelResponse], group: DispatchGroup) {
        let offers = interactor.convertToSubscriptionPlan(offers: allOffers, accountType: accountType)
        group.leave()
        availableOffers = offers.filter({
            guard let model = $0.model as? PackageModelResponse, let type = model.type else { return false }
            return type == .SLCM || type == .apple
        })
        view?.stopActivityIndicator()
        self.view?.reloadPackages()
    }

    func successedGotUserAuthority() {
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
        case .premiumUser:
            router.openLeavePremium()
        case .standard: break
        }
    }
}
