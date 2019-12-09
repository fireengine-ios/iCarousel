//
//  HomePageHomePagePresenter.swift
//  Depo
//
//  Created by AlexanderP on 22/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

final class HomePagePresenter: HomePageModuleInput, HomePageViewOutput, HomePageInteractorOutput, BaseFilesGreedModuleOutput {
    
    private enum DispatchGroupReasons: CaseIterable {
        case waitAccountInfoResponse        ///calls didObtainAccountInfo OR didObtainAccountInfoError
        case waitAccountPermissionsResponse ///regardless response always calls fillCollectionView
        case waitQuotaInfoResponse          ///regardless response always calls didObtainQuotaInfo
        case waitTillViewDidAppear          ///calls viewIsReadyForPopUps
    }
    
    weak var view: HomePageViewInput!
    var interactor: HomePageInteractorInput!
    var router: HomePageRouterInput!
    
    private let spotlightManager = SpotlightManager.shared
    private var cards: [HomeCardResponse] = []
    
    private(set) var allFilesViewType = MoreActionsConfig.ViewType.Grid
    private(set) var allFilesSortType = MoreActionsConfig.SortRullesType.TimeNewOld
    
    private(set) var favoritesViewType = MoreActionsConfig.ViewType.Grid
    private(set) var favoritesSortType = MoreActionsConfig.SortRullesType.TimeNewOld
    
    private var loadCollectionView = false
    private var isShowPopupQuota = false
    private var isFirstAppear = true
    
    private var presentPopUpsGroup: DispatchGroup?
    
    func viewIsReady() {
        prepareDispatchGroup()
        
        interactor.viewIsReady()
    }
    
    func viewWillAppear() {
        spotlightManager.delegate = self
        
        if isFirstAppear {
            AnalyticsService.updateUser()
        } else {
            view.startSpinner()
            interactor.updateLocalUserDetail()
        }
        
        interactor.trackScreen()
    }
    
    func viewIsReadyForPopUps() {
        
        if isFirstAppear {
            isFirstAppear = false
            
            presentPopUpsGroup?.leave()
        }
        
        HomePagePopUpsService.shared.continueAfterPushIfNeeded()
    }
    
    func showSettings() {
        router.moveToSettingsScreen()
    }
    
    func showSearch(output: UIViewController?) {
        router.moveToSearchScreen(output: output)
    }
    
    func onSyncContacts() {
        router.moveToSyncContacts()
    }
    
    func allFilesPressed() {
        router.moveToAllFilesPage()
    }
    
    func favoritesPressed() {
        router.moveToFavouritsFilesPage()
    }
    
    func createStory() {
        router.moveToCreationStory()
    }
    
    func needRefresh() {
        cards.removeAll()
        interactor.needRefresh()
    }
    
    func stopRefresh() {
        view.stopRefresh()
    }
        
    func reloadType(_ type: MoreActionsConfig.ViewType, sortedType: MoreActionsConfig.SortRullesType, fieldType: FieldValue) {
        if fieldType == .all {
            self.allFilesViewType = type
            self.allFilesSortType = sortedType
        } else if fieldType == .favorite {
            self.favoritesViewType = type
            self.favoritesSortType = sortedType
        }
    }
    
    func shownSpotlight(type: SpotlightType) {
        spotlightManager.shownSpotlight(type: type)
    }
    
    func closedSpotlight(type: SpotlightType) {
        spotlightManager.closedSpotlight(type: type)
    }
        
    func requestShowSpotlight(for types: [SpotlightType]) {
        spotlightManager.requestShowSpotlight(for: types)
    }
    
    func showPopupAboutPremiumIfNeeded() {
        if AuthoritySingleton.shared.isShowPopupAboutPremiumAfterRegistration {
            
            AuthoritySingleton.shared.setShowPopupAboutPremiumAfterRegistration(isShow: false)
            AuthoritySingleton.shared.setShowedPopupAboutPremiumAfterLogin(isShow: true)
            
            router.showPopupForNewUser(with: TextConstants.homePagePopup,
                                       title: TextConstants.lifeboxPremium,
                                       headerTitle: TextConstants.becomePremiumMember,
                                       completion: nil)
        }
    }
    
    func didObtainError(with text: String, isNeedStopRefresh: Bool) {
        if isNeedStopRefresh {
            stopRefresh()
        }
        
        router.showError(errorMessage: text)
    }
    
    func didObtainHomeCards(_ cards: [HomeCardResponse]) {
        self.cards = cards
    }
    
    func didObtainInstaPickStatus(status: InstapickAnalyzesCount) {
        CardsManager.default.configureInstaPick(with: status)
    }
    
    func didObtainQuotaInfo(usagePercentage: Float) {
        let storageVars: StorageVars = factory.resolve()
        
        let isFirstLogin = !storageVars.homePageFirstTimeLogin
        if isFirstLogin {
            storageVars.homePageFirstTimeLogin = true
        }
        
        if isFirstLogin {
            let fullOfQuotaPopUpType: LargeFullOfQuotaPopUpType?
            
            if 0.8 <= usagePercentage && usagePercentage < 0.9 {
                fullOfQuotaPopUpType = .LargeFullOfQuotaPopUpType80
                
            } else if 0.9 <= usagePercentage && usagePercentage < 1.0 {
                fullOfQuotaPopUpType = .LargeFullOfQuotaPopUpType90
                
            } else if usagePercentage >= 1.0 {
                fullOfQuotaPopUpType = .LargeFullOfQuotaPopUpType100
                
            } else {
                fullOfQuotaPopUpType = nil
            }
            
            if let type = fullOfQuotaPopUpType {
                router.presentFullOfQuotaPopUp(with: type)
            }
        } else if usagePercentage >= 1.0 {
            router.presentSmallFullOfQuotaPopUp()
        }
        
        presentPopUpsGroup?.leave()
    }
    
    func giftButtonPressed() {
        interactor.trackGiftTapped()
        router.openCampaignDetails()
    }
    
    func fillCollectionView(isReloadAll: Bool) {
        if !AuthoritySingleton.shared.isBannerShowedForPremium {
            CardsManager.default.startPremiumCard()
        }
        
        AuthoritySingleton.shared.hideBannerForSecondLogin()
        
        if cards.isEmpty {
            if !isReloadAll {
                stopRefresh()
            }
            return
        }
        
        if isReloadAll {
            CardsManager.default.startOperatonsForCardsResponses(cardsResponses: cards)
        } else {
            //to hide spinner when refresh only premium card
            stopRefresh()
        }
        
        presentPopUpsGroup?.leave()
    }
    
    func didObtainAccountInfo(accountInfo: AccountInfoResponse) {
        verifyEmailIfNeeded(with: accountInfo)
        credsCheckUpdateIfNeeded(with: accountInfo)
        
        presentPopUpsGroup?.leave()
    }
    
    func didObtainAccountInfoError(with text: String) {
        didObtainError(with: text, isNeedStopRefresh: false)
    }
    
    func showGiftBox() {
        view.showGiftBox()
    }
    
    func hideGiftBox() {
        view.hideGiftBox()
    }
    
    private func prepareDispatchGroup() {
        presentPopUpsGroup = DispatchGroup()
        
        DispatchGroupReasons.allCases.forEach { _ in
            presentPopUpsGroup?.enter()
        }
        
        presentPopUpsGroup?.notify(queue: DispatchQueue.main) { [weak self] in
            self?.presentPopUpsGroup = nil
            self?.router.presentPopUps()
        }
    }
    
    private func verifyEmailIfNeeded(with accountInfo: AccountInfoResponse) {
        guard accountInfo.emailVerified == false else {
            return
        }
        
        router.presentEmailVerificationPopUp()
    }
    
    private func credsCheckUpdateIfNeeded(with accountInfo: AccountInfoResponse) {
        guard accountInfo.isUpdateInformationRequired == true else {
            return
        }
        
        let email = accountInfo.email ?? ""
        let fullPhoneNumber = accountInfo.fullPhoneNumber
        let message = "\(email)\n\(fullPhoneNumber)"
        
        router.presentCredsUpdateCkeckPopUp(message: message, userInfo: accountInfo)
    }
}

//MARK: - SpotlightManagerDelegate
extension HomePagePresenter: SpotlightManagerDelegate {
    
    func needShowSpotlight(type: SpotlightType) {
        if interactor.homeCardsLoaded {
            view.needShowSpotlight(type: type)
        }  
    }
}
