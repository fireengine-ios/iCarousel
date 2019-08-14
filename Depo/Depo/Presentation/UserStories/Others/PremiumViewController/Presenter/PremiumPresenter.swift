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
    var accountType: AccountType = .all
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
        view.displayFeatureInfo(price: price, description: description, isNeedPolicy: accountType != .turkcell)
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
            let price = interactor.getPriceInfo(for: offer, accountType: accountType)
            router.showActivateOfferAlert(with: offer.displayName ?? "", text: price, delegate: self)
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
            var isShouldPass = feature.authorities?.contains(where: { $0.authorityType == authority }) ?? false
            if accountType == .turkcell {
                isShouldPass = isShouldPass && feature.featureType == .appleFeature
            }

            return isShouldPass
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
        optInVC?.stopLoading()
        optInVC?.setupTimer(withRemainingTime: NumericConstants.vereficationTimerLimit)
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
    
    func successedGotAppleInfo() {
        displayFeatureInfo()
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
