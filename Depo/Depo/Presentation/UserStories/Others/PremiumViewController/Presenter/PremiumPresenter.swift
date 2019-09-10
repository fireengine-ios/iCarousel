//
//  PremiumPresenter.swift
//  Depo_LifeTech
//
//  Created by Harbros 3 on 11/16/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class PremiumPresenter {
    
    weak var view: PremiumViewInput!
    var interactor: PremiumInteractorInput!
    var router: PremiumRouterInput!
    
    weak var moduleOutput: FaceImageItemsModuleOutput?
    
    var title: String
    var headerTitle: String
    var authority: AuthorityType = .premiumUser
    var accountType: AccountType = .all
    
    private var userPhone = ""
    
    private var alertText: String = ""
    
    private var optInVC: OptInController?
    private var referenceToken = ""
    private var feature: PackageModelResponse?
    private var availableOffer: PackageOffer?
    
    private let paymentTypes: [FeaturePackageType] = [.SLCMFeature, .appleFeature, .paycellSLCMFeature, .allAccessPaycellFeature]
    
    init(title: String, headerTitle: String, authority: AuthorityType?, module: FaceImageItemsModuleOutput?) {
        self.title = title
        self.headerTitle = headerTitle
        if let authority = authority {
            self.authority = authority
        }
        if let module = module {
            moduleOutput = module
        }
    }
    
    //MARK: Utility Methods(public)
    func buy() {
        SingletonStorage.shared.getAccountInfoForUser(success: { [weak self] userInfoResponse in
            self?.userPhone = userInfoResponse.fullPhoneNumber
            DispatchQueue.toMain {
                self?.view.startActivityIndicator()
                guard let offer = self?.feature else {
                    self?.failed(with: "Couldn't get feature offer for this authority type")
                    return
                }
                self?.interactor.getToken(for: offer)
            }
            }, fail: { [weak self] failResponse in
                DispatchQueue.toMain {
                    self?.view.stopActivityIndicator()
                    self?.failed(with: failResponse.description)
                }
        })
    }
    
    //MARK: Utility Methods(private)
    private func displayFeatureInfo(isError: Bool = false) {
        var price: String?
        let description: String
        
        if let offer = feature {
            price = interactor.getPriceInfo(for: offer, accountType: accountType)
            description = String(format: TextConstants.useFollowingPremiumMembership, price ?? "")
        } else {
            description = isError ? TextConstants.serverErrorMessage : TextConstants.noDetailsMessage
            alertText = description
        }
        
        view.stopActivityIndicator()
        view.displayFeatureInfo(price: price, description: description, isNeedPolicy: accountType != .turkcell)
    }
    
    private func prepareForPurchase() {
        guard let offer = feature else {
            router.showNoDetailsAlert(with: alertText)
            return
        }
        if let plan = availableOffer, let type = offer.featureType, type.isContained(in: paymentTypes) {
            let paymentModel = makePaymentModel(plan: plan)
            router.presentPaymentPopUp(paymentModel: paymentModel)
        } else {
            let price = interactor.getPriceInfo(for: offer, accountType: accountType)
            router.showActivateOfferAlert(with: offer.displayName ?? "", text: price, delegate: self)
        }
    }
    
    private func makePaymentModel(plan: PackageOffer) -> PaymentModel? {
        guard let name = plan.offers.first?.name else {
            assertionFailure()
            return nil
        }
           
        let paymentMethods: [PaymentMethod] = plan.offers.compactMap { offer in
            if let model = offer.model as? PackageModelResponse {
                return createPaymentMethod(model: model, priceString: offer.priceString, offer: plan)
            } else {
                return nil
            }
        }
           
        return PaymentModel(name: name, types: paymentMethods)
    }
    
    private func createPaymentMethod(model: PackageModelResponse, priceString: String, offer: PackageOffer) -> PaymentMethod? {
        guard let name = model.name, let type = model.type?.paymentType else {
            return nil
        }
        
        return PaymentMethod(name: name, priceLabel: priceString, type: type, action: { [weak self] name in
            guard let subscriptionPlan = self?.getChoosenSubscriptionPlan(availableOffers: offer, name: name) else {
                assertionFailure()
                return
            }
            
            if let tag = MenloworksSubscriptionStorage(rawValue: subscriptionPlan.name) {
                MenloworksAppEvents.onSubscriptionClicked(tag)
            }
            
            if let packageModel = subscriptionPlan.model as? PackageModelResponse {
                self?.view.startActivityIndicator()
                self?.interactor.activate(offer: packageModel)
            }
        })
        
    }
    
    private func getChoosenSubscriptionPlan(availableOffers: PackageOffer, name: String ) -> SubscriptionPlan?  {
        return availableOffers.offers.first { plan -> Bool in
            guard let model = plan.model as? PackageModelResponse else {
                return false
            }
            return model.name == name
        }
    }
    
    private func filterPackagesByQuota(offers: [SubscriptionPlan]) -> [PackageOffer] {
        return Dictionary(grouping: offers, by: { $0.quota })
            .compactMap { dict in
                    return PackageOffer(quotaNumber: dict.key, offers: dict.value)
            }.sorted(by: { $0.quotaNumber < $1.quotaNumber })
    }
}

// MARK: - PremiumViewOutput
extension PremiumPresenter: PremiumViewOutput {    
    
    func onViewDidLoad(with premiumView: PremiumView) {
        view.startActivityIndicator()
        premiumView.delegate = self
        interactor.getAccountType()
    }
}

// MARK: - PremiumInteractorOtuput
extension PremiumPresenter: PremiumInteractorOutput {
    //MARK: success
    func successed(accountType: String) {
        if accountType == "TURKCELL" {
            self.accountType = .turkcell
        }
        
        interactor.getFeaturePacks()
    }
    
    func successed(allFeatures: [PackageModelResponse]) {
        feature = allFeatures.first(where: { feature in
            var isShouldPass = feature.authorities?.contains(where: { $0.authorityType == authority }) ?? false
            if accountType == .turkcell {
                isShouldPass = isShouldPass && feature.featureType?.isContained(in: paymentTypes) == true
            }

            return isShouldPass
        })
        
        guard let neededFeature = feature else {
            switchToTextWithoutPrice(isError: false)
            return
        }

        if neededFeature.featureType.isContained(in: paymentTypes) {
            interactor.getInfoForAppleProducts(offer: neededFeature)
        } else {
            displayFeatureInfo()
        }
    }
    
    func successed(tokenForOffer: String) {
        view.stopActivityIndicator()
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
    
    func successedVerifyOffer() {
        optInVC?.stopLoading()
        optInVC?.resignFirstResponder()
        /// to wait popViewController animation
        DispatchQueue.toMain {
            self.router.purchaseSuccessed(with: self.moduleOutput)
        }
    }
    
    func successedGotAppleInfo(offer: PackageModelResponse) {
        displayFeatureInfo()
        let offers = interactor.convertToSubscriptionPlan(offer: offer, accountType: accountType)
        availableOffer = filterPackagesByQuota(offers: offers).first
    }
    
    //MARK: Fail
    func failedVerifyOffer() {
        optInVC?.stopLoading()
        optInVC?.clearCode()
        optInVC?.view.endEditing(true)
        
        if optInVC?.increaseNumberOfAttemps() == false {
            optInVC?.startEnterCode()
            optInVC?.showError(TextConstants.promocodeInvalid)
        }
    }
    
    func switchToTextWithoutPrice(isError: Bool) {
        displayFeatureInfo(isError: isError)
    }
    
    func failed(with errorMessage: String) {
        view?.stopActivityIndicator()
        router.displayError(with: errorMessage)
    }
    
    func failedResendToken(with errorMessage: String) {
        optInVC?.stopLoading()
        optInVC?.showError(errorMessage)
    }

    //MARK: finish purchase
    func purchaseFinished() {
        view?.stopActivityIndicator()
        if let moduleOutput = moduleOutput {
            moduleOutput.didReloadData()
        }
        router.goToBack()
    }
}

// MARK: - OptInControllerDelegate
extension PremiumPresenter: OptInControllerDelegate {
    func optInResendPressed(_ optInVC: OptInController) {
        optInVC.startLoading()
        self.optInVC = optInVC
        guard let offer = feature else {
            self.failed(with: "Couldn't get feature offer for this authority type")
            return
        }
        interactor.getResendToken(for: offer)
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
        guard let offer = feature else {
            self.failed(with: "Couldn't get feature offer for this authority type")
            return
        }
        interactor.verifyOffer(offer, token: referenceToken, otp: code)
    }
}

// MARK: - PremiumViewDelegate
extension PremiumPresenter: PremiumViewDelegate {
    
    func onBecomePremiumTap() {
        prepareForPurchase()
    }
    
    func openLink(with url: URL) {
        router.openLink(with: url)
    }
    
    func showTermsOfUse() {
        router.showTermsOfUse()
    }
}
