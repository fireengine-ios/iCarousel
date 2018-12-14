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
    
    private var optInVC: OptInController?
    private var referenceToken = ""
    private var accountType: AccountType = .all
    private var feature: PackageModelResponse? {
        didSet {
            displayFeatureInfo()
        }
    }
    
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
    private func displayFeatureInfo() {
        let price: String
        guard let offer = feature else {
            view.stopActivityIndicator()
            view.displayFeatureInfo(price: nil)
            return
        }
        
        price = interactor.getPriceInfo(for: offer, accountType: accountType)
        
        view.stopActivityIndicator()
        view.displayFeatureInfo(price: price)
    }
    
    private func prepareForPurchase() {
        guard let offer = feature else {
            router.showNoDetailsAlert()
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
        interactor.getFeaturePacks(isAppleProduct: self.accountType == .all)
    }
    
    func successed(allFeatures: [PackageModelResponse]) {
        let featureType: FeaturePackageType = accountType == .all ? .appleFeature : .SLCMFeature
        for feature in allFeatures {
            if feature.featureType == featureType {
                guard let authorities = feature.authorities else { continue }
                if authorities.contains(where: { return $0.authorityType == authority }) {
                    self.feature = feature
                    break
                }
            }
        }
        
        if feature == nil {
            switchToTextWithoutPrice()
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
            self.router.purchaseSuccessed()
        }
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
    
    func switchToTextWithoutPrice() {
        displayFeatureInfo()
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
