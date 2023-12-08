//
//  DiscoverInteractor.swift
//  Lifebox
//
//  Created by Ozan Salman on 17.11.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

final class DiscoverInteractor: DiscoverInteractorInput {
    
    private enum RefreshStatus {
        case reloadAll
        case reloadSingle
    }
    weak var output: DiscoverInteractorOutput!
    private lazy var homeCardsService: HomeCardsService = factory.resolve()
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    private lazy var instapickService: InstapickService = factory.resolve()
    private lazy var accountService = AccountService()
    private lazy var storageVars: StorageVars = factory.resolve()
    private let smartAlbumsManager: SmartAlbumsManager = factory.resolve()
    private let campaignService = CampaignServiceImpl()
    private var isShowPopupAboutPremium = true
    private(set) var homeCardsLoaded = false
    private var isFirstAuthorityRequest = true
    
    private func fillCollectionView(isReloadAll: Bool) {
        self.homeCardsLoaded = true
        self.output.fillCollectionView(isReloadAll: isReloadAll)
    }

    func viewIsReady() {
        homeCardsService.delegate = self
        //FreeAppSpace.session.showFreeUpSpaceCard()
        FreeAppSpace.session.checkFreeUpSpace()
        setupAutoSyncTriggering()

        getQuotaInfo()
        getAccountInfo()
        getPremiumCardInfo(loadStatus: .reloadAll)
        getAllCardsForHomePage()
        getCampaignStatus()
        
        smartAlbumsManager.requestAllItems()
        
        //handle public shared items save operation after login
        if let publicTokenToSave = storageVars.publicSharedItemsToken {
            savePublicSharedItems(with: publicTokenToSave)
            storageVars.publicSharedItemsToken = nil
        }
    }
    
    func needRefresh() {
        homeCardsLoaded = false
        
        getCampaignStatus()
        getPremiumCardInfo(loadStatus: .reloadAll)
        getAllCardsForHomePage()
    }

    func updateLocalUserDetail() {
        getPremiumCardInfo(loadStatus: .reloadSingle)
        getInstaPickInfo()
    }
    
    //MARK: tracking
    func trackScreen() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.HomePageScreen())
        analyticsService.logScreen(screen: .homePage)
        analyticsService.trackDimentionsEveryClickGA(screen: .homePage)
    }
    
    func trackGiftTapped() {
        analyticsService.trackCustomGAEvent(eventCategory: .campaign, eventActions: .giftIcon, eventLabel: .empty)
    }
    
    func trackQuota(quotaPercentage: Float) {
        var quotaUsed: Int
        switch quotaPercentage {
        case 0.8..<0.9:
            quotaUsed = 80
        case 0.9..<0.95:
            quotaUsed = 90
        case 0.95..<1:
            quotaUsed = 95
        case 1...:
            quotaUsed = 100
        default:
            return
        }
        analyticsService.trackCustomGAEvent(eventCategory: .functions,
                                            eventActions: .quota,
                                            eventLabel: .quotaUsed(quotaUsed))
    }
    
    //MARK: autosync triggering

    private func setupAutoSyncTriggering() {
        SyncServiceManager.shared.setupAutosync()
        SyncServiceManager.shared.update()
    }
    
    //MARK: private requests
    private func getCampaignStatus() {
        campaignService.getPhotopickDetails { [weak self] result in
            switch result {
            case let .success(response):
                let dates = response.dates
                let isActive = Date().isInRange(start: dates.startDate, end: dates.launchDate)

                if isActive && SingletonStorage.shared.isUserFromTurkey {
                    DispatchQueue.toMain {
                        self?.output.showGiftBox()
                    }
                }
            case let .failure(error):
                switch error {
                case .empty:
                    DispatchQueue.toMain {
                        self?.output.hideGiftBox()
                    }
                default:
                    break
                }
            }
        }
    }
    
    private func getAccountInfo() {
        SingletonStorage.shared.getAccountInfoForUser(success: { [weak self] accountInfo in
            DispatchQueue.toMain {
                self?.output.didObtainAccountInfo(accountInfo: accountInfo)
            }
        }, fail: { [weak self] error in
            DispatchQueue.toMain {
                self?.output.didObtainAccountInfoError(with: error.description)
            }
        })
    }
    
    private func getAllCardsForHomePage() {
        homeCardsService.all { [weak self] result in
            DispatchQueue.main.async {
                self?.output.stopRefresh()
                switch result {
                case .success(let response):
                    self?.output.didObtainHomeCards(response)
                    self?.fillCollectionView(isReloadAll: true)
                case .failed(let error):
                    DispatchQueue.toMain {
                        self?.output.didObtainError(with: error.description, isNeedStopRefresh: true)
                    }
                }
            }
        }
    }
    
    private func getPremiumCardInfo(loadStatus: RefreshStatus) {
        accountService.permissions { [weak self] response in
            switch response {
            case .success(let result):
                AuthoritySingleton.shared.refreshStatus(with: result)
                
                if self?.isFirstAuthorityRequest == true {
                    AnalyticsService.updateUser()
                    self?.isFirstAuthorityRequest = false
                }

                SingletonStorage.shared.getAccountInfoForUser(success: { [weak self] response in
                    DispatchQueue.main.async {
                        self?.fillCollectionView(isReloadAll: loadStatus == .reloadAll)
                    }
                }, fail: { [weak self] error in
                    DispatchQueue.main.async {
                        self?.fillCollectionView(isReloadAll: true)

                        self?.output.didObtainError(with: error.description,
                                                           isNeedStopRefresh: loadStatus == .reloadSingle)
                    }
                })
                
                if self?.isShowPopupAboutPremium == true {
                    self?.isShowPopupAboutPremium = false
                }
            case .failed(let error):
                DispatchQueue.toMain {
                    if !error.isNetworkError {
                        self?.fillCollectionView(isReloadAll: true)
                    }
                    
                    self?.output.didObtainError(with: error.description,
                                                       isNeedStopRefresh: loadStatus == .reloadSingle)
                }
            }
        }
    }
    
    private func getInstaPickInfo() {
        instapickService.getAnalyzesCount { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let response):
                self.output.didObtainInstaPickStatus(status: response)
            case .failed(let error):
                DispatchQueue.toMain {
                    self.output.didObtainError(with: error.description, isNeedStopRefresh: true)
                }
            }
        }
    }
    
    private func getQuotaInfo() {
        accountService.quotaInfo(success: { [weak self] response in
            DispatchQueue.main.async {
                guard
                    let qresponse = response as? QuotaInfoResponse,
                    let quotaBytes = qresponse.bytes,
                    let usedBytes = qresponse.bytesUsed
                else {
                    self?.output.didObtainQuotaInfo(usagePercentage: 0)
                    assertionFailure("quota info is missing")
                    return
                }
                
                let usagePercent = Float(usedBytes) / Float(quotaBytes)
                self?.trackQuota(quotaPercentage: usagePercent)
                
                self?.output.didObtainQuotaInfo(usagePercentage: usagePercent)
            }
            
        }, fail: { [weak self] error in
            DispatchQueue.main.async {
                self?.output.didObtainQuotaInfo(usagePercentage: 0)
                self?.output.didObtainError(with: error.description, isNeedStopRefresh: false)
            }
        })
    }
    
    func getPermissionAllowanceInfo(type: PermissionType) {
        accountService.getPermissionAllowanceInfo(withType: type, handler: { [weak self] response in
            switch response {
            case .success(let response):
                DispatchQueue.main.async {
                    self?.output.didObtainPermissionAllowance(response: response)
                }
            case .failed(_):
                // do nothing
                break
            }
        })
    }
    
    func updateMobilePaymentPermissionFeedback() {
        accountService.updateMobilePaymentPermissionFeedback() { response in
            switch response {
            case .success(_):
                debugPrint("updateMobilePaymentPermissionFeedback: success")
                return
            case .failed(_):
                debugPrint("updateMobilePaymentPermissionFeedback: fail")
                return
            }
        }
    }
    
    func changePermissionsAllowed(type: PermissionType, isApproved: Bool) {
        accountService.changePermissionsAllowed(type: type, isApproved: isApproved) { [weak self] response in
            guard let self = self else {
                return
            }
            switch response {
            case .success(_):
                self.output.showSuccessMobilePaymentPopup()
            case .failed(let error):
                UIApplication.showErrorAlert(message: error.description)
            }
        }
    }
    
    private func savePublicSharedItems(with publicTokenToSave: String) {
        PublicSharedItemsService().savePublicSharedItems(publicToken: publicTokenToSave) { value in
            self.output.publicShareSaveSuccess()
            ItemOperationManager.default.publicShareItemsAdded()
        } fail: { error in
            if error.errorDescription == PublicShareSaveErrorStatus.notRequiredSpace.rawValue {
                self.output.publicShareSaveStorageFail()
                return
            }
            let message = PublicShareSaveErrorStatus.allCases.first(where: {$0.rawValue == error.errorDescription})?.description
            self.output.publicShareSaveFail(message: message ?? localized(.publicShareSaveError))
        }
    }
}

extension DiscoverInteractor: HomeCardsServiceImpDelegte {
 
    func albumHiddenSuccessfully(_ successfully: Bool) {
        let message = successfully ? TextConstants.hideSingleAlbumSuccessPopupMessage : TextConstants.temporaryErrorOccurredTryAgainLater
        output.showSnackBarWith(message: message)
    }
        
    func needUpdateHomeScreen() {
        getAllCardsForHomePage()
    }
    
    func showSpinner() {
        output.showSpinner()
    }
    
    func hideSpinner() {
        output.hideSpinner()
    }
}


