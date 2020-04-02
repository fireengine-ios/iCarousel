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
    
    var authority: AuthorityType = .premiumUser
    var accountType: AccountType = .all
    
    private var userPhone = ""
    
    private var alertText: String = ""
    
    private let source: BecomePremiumViewSourceType
    private var optInVC: OptInController?
    private var referenceToken = ""
    private var featureToBuy: PackageModelResponse?
    private var features = [PackageModelResponse]()
    private var availableOffers = [PackageOffer]()

    
    init(authority: AuthorityType?, source: BecomePremiumViewSourceType, module: FaceImageItemsModuleOutput?) {
        if let authority = authority {
            self.authority = authority
        }
        if let module = module {
            moduleOutput = module
        }
        self.source = source
    }
    
    //MARK: Utility Methods(public)
    func buy() {
        SingletonStorage.shared.getAccountInfoForUser(success: { [weak self] userInfoResponse in
            self?.userPhone = userInfoResponse.fullPhoneNumber
            DispatchQueue.toMain {
                self?.view.startActivityIndicator()
                guard let offer = self?.featureToBuy else {
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
        
        if let offer = features.first {
            price = interactor.getPriceInfo(for: offer, accountType: accountType)
            description = String(format: TextConstants.useFollowingPremiumMembership, price ?? "")
        } else {
            /// server sent us nothing. we should have at least one feature.
            description = isError ? TextConstants.serverErrorMessage : TextConstants.noDetailsMessage
            alertText = description
        }
        
        view.stopActivityIndicator()
    }
    
    private func prepareForPurchase(_ offer: PackageOffer) {
        let model = makePaymentModel(plan: offer)
        router.presentPaymentPopUp(paymentModel: model)
    }
    
    private func makePaymentModel(plan: PackageOffer) -> PaymentModel? {
        let paymentMethods: [PaymentMethod] = plan.offers.compactMap { offer in
            if let model = offer.model as? PackageModelResponse {
                return createPaymentMethod(model: model, priceString: offer.price, offer: plan)
            } else {
                return nil
            }
        }
        
        let subtitle = TextConstants.feature
        return PaymentModel(name: TextConstants.standardBannerTitle, subtitle: subtitle, types: paymentMethods)
    }
    
    private func createPaymentMethod(model: PackageModelResponse, priceString: String, offer: PackageOffer) -> PaymentMethod? {
        guard let name = model.name, let type = model.type else {
            return nil
        }
        
        let paymentType = type.paymentType
        return PaymentMethod(name: name, priceLabel: priceString, type: paymentType, action: { [weak self] in
            guard let subscriptionPlan = self?.getChoosenSubscriptionPlan(availableOffers: offer, type: type) else {
                assertionFailure()
                return
            }
            
            let analyticsService: AnalyticsService = factory.resolve()
            
            let eventLabel: GAEventLabel = .paymentType(paymentType.quotaPaymentType(quota: "Premium"))
            analyticsService.trackCustomGAEvent(eventCategory: .functions,
                                                eventActions: .clickFeaturePurchase,
                                                eventLabel: eventLabel)
            
            self?.didPressOn(plan: subscriptionPlan)
        })
    }
    
    private func didPressOn(plan: SubscriptionPlan) {
        router.closePaymentPopUpController(closeAction: { [weak self] in
            self?.actionFor(plan: plan)
        })
    }
    
    private func actionFor(plan: SubscriptionPlan) {
        interactor.trackPackageClick(plan: plan)
        
        guard let model = plan.model as? PackageModelResponse else {
            assertionFailure()
            return
        }
        
        featureToBuy = model
        
        model.type?.purchaseActions( slcm: { [weak self] in
            self?.view.startActivityIndicator()
            self?.buy()
        }, apple: { [weak self] in
            self?.view.startActivityIndicator()
            self?.interactor.activate(offer: model)
        }, paycell: { [weak self] in
            guard let offerId = model.cpcmOfferId else {
                assertionFailure()
                return
            }
            self?.view?.showPaycellProcess(with: offerId)
        }, notPaymentType: { [weak self] in
            assertionFailure("should not be another purchase options")
            let error = CustomErrors.serverError("This is not buyable offer type")
            self?.failed(with: error.localizedDescription)
        })
    }
    
    private func getChoosenSubscriptionPlan(availableOffers: PackageOffer, type: PackageContentType) -> SubscriptionPlan?  {
        return availableOffers.offers.first { plan -> Bool in
            guard let model = plan.model as? PackageModelResponse, let packageType = model.type else {
                return false
            }
            return packageType == type
        }
    }
    
    private func groupOffers(_ offers: [SubscriptionPlan]) -> [PackageOffer] {
        return Dictionary(grouping: offers, by: { $0.isRecommended ? 1 : 0 })
            .compactMap { PackageOffer(quotaNumber: $0.key, offers: $0.value) }
            .sorted(by: { $0.quotaNumber < $1.quotaNumber })
    }
}

// MARK: - PremiumViewOutput
extension PremiumPresenter: PremiumViewOutput {    
    
    func onViewDidLoad(with premiumView: BecomePremiumView) {
        view.startActivityIndicator()
        premiumView.source = source
        premiumView.delegate = self
        interactor.getAccountType()
        interactor.trackScreen()
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
        features = allFeatures.filter { $0.isFeaturePack == true && $0.type?.isPaymentType == true }
        features.append(allFeatures.first(where: { $0.isRecommendedPremium }))
        
        guard features.hasItems else {
            switchToTextWithoutPrice(isError: false)
            /// maybe will be need. clear if all tests will be done by QA
            //displayFeatureInfo()
            return
        }
        
        interactor.getInfoForAppleProducts(offers: features)
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
    
    func successedGotAppleInfo(offers: [PackageModelResponse]) {
        let plans = interactor.convertToSubscriptionPlan(offers: offers, accountType: accountType)
        
        let offers = groupOffers(plans)
            .sorted(by: { ($0.offers.first?.isRecommended == false) && $1.offers.first?.isRecommended == true })
        view.stopActivityIndicator()
        view.displayOffers(offers)
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
        guard let offer = featureToBuy else {
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
        guard let offer = featureToBuy else {
            self.failed(with: "Couldn't get feature offer for this authority type")
            return
        }
        interactor.verifyOffer(offer, token: referenceToken, otp: code)
    }
}

//MARK: - BecomePremiumViewDelegate

extension PremiumPresenter: BecomePremiumViewDelegate {
    func didSelectSubscriptionPlan(_ offer: PackageOffer) {
        prepareForPurchase(offer)
    }
    
    func didTapSeeAllPackages() {
        router.showAllPackages()
    }
}
