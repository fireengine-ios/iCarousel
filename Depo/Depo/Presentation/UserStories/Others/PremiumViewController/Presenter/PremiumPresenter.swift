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
    
    private var userPhone = ""
    
    private var alertText: String = ""
    
    private var optInVC: OptInController?
    private var referenceToken = ""
    private var accountType: AccountType = .all
    private var feature: PackageModelResponse?
    
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
        view.displayFeatureInfo(price: price, description: description)
    }
    
    private func prepareForPurchase() {
        guard let offer = feature else {
            router.showNoDetailsAlert(with: alertText)
            return
        }
        if let type = offer.featureType, type == .appleFeature {
            view.startActivityIndicator()
            interactor.activate(offer: offer)
        } else {
            let bodyText = "\(offer.period ?? "") \(offer.price ?? 0)"
            router.showActivateOfferAlert(with: offer.displayName ?? "", text: bodyText, delegate: self)
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
            return feature.authorities?.contains(where: { $0.authorityType == authority }) ?? false
        })
        
        guard let neededFeature = feature else {
            switchToTextWithoutPrice(isError: false)
            return
        }

        if neededFeature.featureType == .appleFeature {
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
        optInVC?.stopActivityIndicator()
        optInVC?.setupTimer(withRemainingTime: NumericConstants.vereficationTimerLimit)
        optInVC?.startEnterCode()
        optInVC?.hideResendButton()
    }
    
    func successedVerifyOffer() {
        optInVC?.stopActivityIndicator()
        optInVC?.resignFirstResponder()
        /// to wait popViewController animation
        DispatchQueue.toMain {
            self.router.purchaseSuccessed(with: self.moduleOutput)
        }
    }
    
    func successedGotAppleInfo() {
        displayFeatureInfo()
    }
    
    //MARK: Fail
    func failedVerifyOffer() {
        optInVC?.stopActivityIndicator()
        optInVC?.clearCode()
        optInVC?.view.endEditing(true)
        
        if optInVC?.increaseNumberOfAttemps() == false {
            router.showPromocodInvalideAlert(for: optInVC)
        }
    }
    
    func switchToTextWithoutPrice(isError: Bool) {
        displayFeatureInfo(isError: isError)
    }
    
    func failed(with errorMessage: String) {
        view?.stopActivityIndicator()
        router.displayError(with: errorMessage)
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
        optInVC.startActivityIndicator()
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
        let error = CustomErrors.serverError(TextConstants.promocodeBlocked)
        router.displayError(with: error.localizedDescription)
    }
    
    func optInNavigationTitle() -> String {
        return TextConstants.optInNavigarionTitle
    }
    
    func optIn(_ optInVC: OptInController, didEnterCode code: String) {
        optInVC.startActivityIndicator()
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
    
}
