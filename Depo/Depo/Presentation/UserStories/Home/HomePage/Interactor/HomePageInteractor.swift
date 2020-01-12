//
//  HomePageHomePageInteractor.swift
//  Depo
//
//  Created by AlexanderP on 22/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//


final class HomePageInteractor: HomePageInteractorInput {

    private enum RefreshStatus {
        case reloadAll
        case reloadSingle
    }
    
    weak var output: HomePageInteractorOutput!
    
    private lazy var homeCardsService: HomeCardsService = HomeCardsServiceImp()
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    private lazy var instapickService: InstapickService = factory.resolve()
    private lazy var accountService = AccountService()

    private let smartAlbumsManager: SmartAlbumsManager = factory.resolve()
    private let campaignService = CampaignServiceImpl()

    private var isShowPopupAboutPremium = true
    private(set) var homeCardsLoaded = false
    
    private func fillCollectionView(isReloadAll: Bool) {
        self.homeCardsLoaded = true
        self.output.fillCollectionView(isReloadAll: isReloadAll)
    }

    func viewIsReady() {
        FreeAppSpace.session.checkFreeAppSpace()
        setupAutoSyncTriggering()
        PushNotificationService.shared.openActionScreen()
        
        getQuotaInfo()
        getAccountInfo()
        getPremiumCardInfo(loadStatus: .reloadAll)
        getAllCardsForHomePage()
        getCampaignStatus()
        
        smartAlbumsManager.requestAllItems()
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
    @objc private func checkAutoSync() {
        SyncServiceManager.shared.updateImmediately()
    }
    
    private func setupAutoSyncTriggering() {
        SyncServiceManager.shared.setupAutosync()
        SyncServiceManager.shared.updateImmediately()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(checkAutoSync),
                                               name: .UIApplicationWillEnterForeground,
                                               object: nil)
    }
    
    //MARK: private requests
    private func getCampaignStatus() {
        campaignService.getPhotopickDetails { [weak self] result in
            switch result {
            case .success(let status):
                if SingletonStorage.shared.isUserFromTurkey,
                    (status.startDate...status.launchDate).contains(Date()) {
                    DispatchQueue.toMain {
                        self?.output.showGiftBox()
                    }
                }
            case .failure(let errorResult):
                if errorResult.isEmpty() {
                    DispatchQueue.toMain {
                        self?.output.hideGiftBox()
                    }
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
                    self?.output.showPopupAboutPremiumIfNeeded()
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
}
