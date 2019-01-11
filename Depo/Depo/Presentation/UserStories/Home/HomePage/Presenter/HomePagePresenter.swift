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
        
        if isShowPopupQuota {
            isShowPopupQuota = false
            interactor.needCheckQuota()
        }
        
        if isShowPopupAboutPremium {
            isShowPopupAboutPremium = false
            router.showPopupForNewUser(with: TextConstants.descriptionAboutStandartUser,
                                       title: TextConstants.lifeboxPremium,
                                       headerTitle: TextConstants.becomePremiumMember, completion: nil)
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
    
    func needPresentPopUp(popUpView: UIViewController) {
        view.needPresentPopUp(popUpView: popUpView)
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
    
    func didShowPopupAboutPremium() {
        if AuthoritySingleton.shared.isShowPopupAboutPremiumAfterRegistration {
            AuthoritySingleton.shared.setShowPopupAboutPremiumAfterRegistration(isShow: false)
            AuthoritySingleton.shared.setShowedPopupAboutPremiumAfterLogin(isShow: true)
            router.showPopupForNewUser(with: TextConstants.homePagePopup,
                                                                  title: TextConstants.lifeboxPremium,
                                                                  headerTitle: TextConstants.becomePremiumMember, completion: nil)
        } else if !AuthoritySingleton.shared.isShowedPopupAboutPremiumAfterLogin,
            !AuthoritySingleton.shared.isPremium,
            AuthoritySingleton.shared.isLoginAlready {
            AuthoritySingleton.shared.setShowedPopupAboutPremiumAfterLogin(isShow: true)
            router.showPopupForNewUser(with: TextConstants.descriptionAboutStandartUser,
                                       title: TextConstants.lifeboxPremium,
                                       headerTitle: TextConstants.becomePremiumMember, completion: { [weak self] in
                                        self?.isShowPopupQuota = true
            })
        }
    }
    
    func didObtainFailCardInfo(errorMessage: String) {
        router.showError(errorMessage: errorMessage)
    }
    
    func didObtainHomeCards(_ cards: [HomeCardResponse]) {
        self.cards = cards
    }
    
    func didObtainInstaPickStatus(status: AnalysisCount) {
        CardsManager.default.configureInstaPick(analysisLeft: status.left, totalCount: status.total)
    }
    
    func fillCollectionView(isReloadAll: Bool) {
        
        if !AuthoritySingleton.shared.isBannerShowedForPremium {
            CardsManager.default.startPremiumCard()
        }
        AuthoritySingleton.shared.hideBannerForSecondLogin()
        
        if isReloadAll {
            CardsManager.default.startOperatonsForCardsResponces(cardsResponces: cards)
        } else {
            //to hide spinner when refresh only premium card
            view.stopRefresh()
        }
    }
    
    func didOpenExpand() {
        isShowPopupAboutPremium = true
    }
}

extension HomePagePresenter: SpotlightManagerDelegate {
    
    func needShowSpotlight(type: SpotlightType) {
        if interactor.homeCardsLoaded {
            view.needShowSpotlight(type: type)
        }  
    }
}
