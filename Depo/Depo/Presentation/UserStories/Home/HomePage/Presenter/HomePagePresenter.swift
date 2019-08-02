//
//  HomePageHomePagePresenter.swift
//  Depo
//
//  Created by AlexanderP on 22/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class HomePagePresenter: HomePageModuleInput, HomePageViewOutput, HomePageInteractorOutput, BaseFilesGreedModuleOutput {
    
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
    private var isFirstAppear = true
    
    private var isShowPopupQuota = false
    private var isShowPopupAboutPremium = false

    func viewIsReady() {
        spotlightManager.delegate = self
        interactor.trackScreen()
        
        if !isFirstAppear {
            view.startSpinner()
            interactor.updateLocalUserDetail()
        } else {
            isFirstAppear = false
        }
    }
    
    func homePagePresented() {
        interactor.homePagePresented()
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
    
    func needCheckQuota() {
        interactor.needCheckQuota()
    }
    
    @discardableResult
    func didShowPopupAboutPremium() -> Bool {
        var willShow = false
        if AuthoritySingleton.shared.isShowPopupAboutPremiumAfterRegistration {
            AuthoritySingleton.shared.setShowPopupAboutPremiumAfterRegistration(isShow: false)
            AuthoritySingleton.shared.setShowedPopupAboutPremiumAfterLogin(isShow: true)
            router.showPopupForNewUser(with: TextConstants.homePagePopup,
                                       title: TextConstants.lifeboxPremium,
                                       headerTitle: TextConstants.becomePremiumMember, completion: nil)
            willShow = true
        }
        
        return willShow
    }
    
    func didObtainFailCardInfo(errorMessage: String, isNeedStopRefresh: Bool) {
        if isNeedStopRefresh {
            view.stopRefresh()
        }
        router.showError(errorMessage: errorMessage)
    }
    
    func didObtainHomeCards(_ cards: [HomeCardResponse]) {
        self.cards = cards
    }
    
    func didObtainInstaPickStatus(status: InstapickAnalyzesCount) {
        CardsManager.default.configureInstaPick(with: status)
    }
    
    func didObtainQuotaInfo(usagePercentage: Float) {
        let storageVars: StorageVars = factory.resolve()
        
        let isFirstTime = !storageVars.homePageFirstTimeLogin
        if isFirstTime {
            storageVars.homePageFirstTimeLogin = true
        }
        
        if isFirstTime {
            var fullOfQuotaPopUpType: LargeFullOfQuotaPopUpType?
            
            if 0.8 <= usagePercentage && usagePercentage < 0.9 {
                fullOfQuotaPopUpType = .LargeFullOfQuotaPopUpType80
            }
            else if 0.9 <= usagePercentage && usagePercentage < 1.0 {
                fullOfQuotaPopUpType = .LargeFullOfQuotaPopUpType90
            }
            else if usagePercentage >= 1.0 {
                fullOfQuotaPopUpType = .LargeFullOfQuotaPopUpType100
            }
            
            if let type = fullOfQuotaPopUpType {
                router.presentFullOfQuotaPopUp(with: type)
            }
        } else if usagePercentage >= 1.0 {
            router.presentSmallFullOfQuotaPopUp()
        }
    }
    
    func fillCollectionView(isReloadAll: Bool) {
        
        if !AuthoritySingleton.shared.isBannerShowedForPremium {
            CardsManager.default.startPremiumCard()
        }
        AuthoritySingleton.shared.hideBannerForSecondLogin()
        
        guard !cards.isEmpty else {
            if !isReloadAll {
                view.stopRefresh()
            }
            return
        }
        
        if isReloadAll {
            CardsManager.default.startOperatonsForCardsResponces(cardsResponces: cards)
        } else {
            //to hide spinner when refresh only premium card
            view.stopRefresh()
        }
    }

    func verifyEmailIfNeeded() {
        if let accountInfo = SingletonStorage.shared.accountInfo, !(accountInfo.emailVerified ?? false) {
            router.presentEmailVerificationPopUp(delegate: self)
        }
    }
    
}

extension HomePagePresenter: SpotlightManagerDelegate {
    
    func needShowSpotlight(type: SpotlightType) {
        if interactor.homeCardsLoaded {
            view.needShowSpotlight(type: type)
        }  
    }
}

extension HomePagePresenter: VerifyEmailPopUpDelegate {
    func popUpWillDismiss() {
        if !didShowPopupAboutPremium() {
            router.showIgnoredQuotaPopUpIfNeeded()
        }
    }
}
