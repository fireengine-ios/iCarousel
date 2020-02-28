//
//  HomePageHomePagePresenter.swift
//  Depo
//
//  Created by AlexanderP on 22/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

final class HomePagePresenter: HomePageModuleInput {
    
    private enum DispatchGroupReason: CaseIterable {
        case waitAccountInfoResponse        ///calls didObtainAccountInfo OR didObtainAccountInfoError
        case waitPermissionAllowanceResponse ///calls didObtainPermissionAllowance OR nothing
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
    private var dispatchGroupReasons = [DispatchGroupReason]()
    
    private func decreaseDispatchGroupValue(for reason: DispatchGroupReason) {
        guard let index = dispatchGroupReasons.firstIndex(of: reason) else {
            return
        }
        
        dispatchGroupReasons.remove(at: index)
        presentPopUpsGroup?.leave()
    }
    
}

// MARK: - BaseFilesGreedModuleOutput
extension HomePagePresenter: BaseFilesGreedModuleOutput {
    
    func reloadType(_ type: MoreActionsConfig.ViewType, sortedType: MoreActionsConfig.SortRullesType, fieldType: FieldValue) {
        if fieldType == .all {
            self.allFilesViewType = type
            self.allFilesSortType = sortedType
        } else if fieldType == .favorite {
            self.favoritesViewType = type
            self.favoritesSortType = sortedType
        }
    }
    
}

// MARK: - HomePageInteractorOutput
extension HomePagePresenter: HomePageInteractorOutput {
    
    func stopRefresh() {
        view.stopRefresh()
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
        
        decreaseDispatchGroupValue(for: .waitAccountPermissionsResponse)
    }
    
    func didObtainQuotaInfo(usagePercentage: Float) {
        let storageVars: StorageVars = factory.resolve()
        let fullOfQuotaPopUpType: LargeFullOfQuotaPopUpType?
        
        if usagePercentage < 0.8 {
            fullOfQuotaPopUpType = nil
            
            ///if user's quota is below %80 percent , we change it to false to show next extend quota
            storageVars.largeFullOfQuotaPopUpShownBetween80And99 = false
            
        } else if 0.8 <= usagePercentage && usagePercentage <= 0.99 && !storageVars.largeFullOfQuotaPopUpShownBetween80And99 {
            fullOfQuotaPopUpType = .LargeFullOfQuotaPopUpTypeBetween80And99(usagePercentage)
            storageVars.largeFullOfQuotaPopUpShownBetween80And99 = true
            
        } else if usagePercentage >= 1.0 && storageVars.largeFullOfQuotaPopUpShowType100 && !storageVars.largeFullOfQuotaPopUpCheckBox  {
            let userPremium = storageVars.largeFullOfQuotaUserPremium;
            fullOfQuotaPopUpType = .LargeFullOfQuotaPopUpType100(userPremium)
            storageVars.largeFullOfQuotaPopUpShowType100 = false
        } else {
            fullOfQuotaPopUpType = nil
        }
        
        if let type = fullOfQuotaPopUpType {
            router.presentFullOfQuotaPopUp(with: type)
        }
        
        
        decreaseDispatchGroupValue(for: .waitQuotaInfoResponse)
    }
    
    func didObtainAccountInfo(accountInfo: AccountInfoResponse) {
        verifyEmailIfNeeded(with: accountInfo)
        credsCheckUpdateIfNeeded(with: accountInfo)
        checkMobilePaymentPermission(with: accountInfo)
        decreaseDispatchGroupValue(for: .waitAccountInfoResponse)
    }
    
    func didObtainAccountInfoError(with text: String) {
        didObtainError(with: text, isNeedStopRefresh: false)
    }
    
    func didObtainInstaPickStatus(status: InstapickAnalyzesCount) {
        CardsManager.default.configureInstaPick(with: status)
    }
    
    func showGiftBox() {
        view.showGiftBox()
    }
    
    func hideGiftBox() {
        view.hideGiftBox()
    }
    
    func didObtainPermissionAllowance(response: SettingsPermissionsResponse) {
        decreaseDispatchGroupValue(for: .waitPermissionAllowanceResponse)
        guard let eulaURL = response.eulaURL else {
            // do nothing
            return
        }
        shouldPermissionPopupAppear(response: response) ? router.presentMobilePaymentPermissionPopUp(url: eulaURL, isFirstAppear: true) : ()
    }
    
    // MARK: - HomePageInteractorOutput Private Utility Methods
    
    private func prepareDispatchGroup() {
        presentPopUpsGroup = DispatchGroup()
        
        dispatchGroupReasons = DispatchGroupReason.allCases
        dispatchGroupReasons.forEach { _ in
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
    
    private func checkMobilePaymentPermission(with accountInfo: AccountInfoResponse) {
        guard accountInfo.isUpdateMobilePaymentPermissionRequired == true else {
            decreaseDispatchGroupValue(for: .waitPermissionAllowanceResponse)
            return
        }
        interactor.getPermissionAllowanceInfo(type: .mobilePayment)
    }
    
    private func shouldPermissionPopupAppear(response: SettingsPermissionsResponse) -> Bool {
        guard
            let isAllowed = response.isAllowed,
            let isApproved = response.isApproved,
            let isEulaApproved = response.isApproved,
            isAllowed,
            !isApproved || (isApproved && !isEulaApproved)
        else {
            return false
        }
        return true
    }
    
}

// MARK: - HomePageViewOutput
extension HomePagePresenter: HomePageViewOutput {
    
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
            
            decreaseDispatchGroupValue(for: .waitTillViewDidAppear)
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
    
    func shownSpotlight(type: SpotlightType) {
        spotlightManager.shownSpotlight(type: type)
    }
    
    func closedSpotlight(type: SpotlightType) {
        spotlightManager.closedSpotlight(type: type)
    }
        
    func requestShowSpotlight(for types: [SpotlightType]) {
        spotlightManager.requestShowSpotlight(for: types)
    }
    
    func giftButtonPressed() {
        interactor.trackGiftTapped()
        router.openCampaignDetails()
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
