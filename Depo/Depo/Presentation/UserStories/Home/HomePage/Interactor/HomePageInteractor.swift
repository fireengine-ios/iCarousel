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
    
    private lazy var homeCardsService: HomeCardsService = factory.resolve()
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    private lazy var instapickService: InstapickService = factory.resolve()
    private let subscriptionsService: SubscriptionsService = SubscriptionsServiceIml()
    private lazy var accountService = AccountService()
    private let packageService = PackageService()
    private lazy var storageVars: StorageVars = factory.resolve()
    
    private let smartAlbumsManager: SmartAlbumsManager = factory.resolve()
    private let campaignService = CampaignServiceImpl()
    
    private var isShowPopupAboutPremium = true
    private var isShowPopupDiscoverCard = true
    private(set) var homeCardsLoaded = false
    private var isFirstAuthorityRequest = true
    private var bannerCallMethodCount: Int = 0
    private var isPaidPackage: Bool = false
    private var highlightedPackage: SubscriptionPlan?
    private var highlightedPackageIndex: Int = 0
    
    private var groupDate: [Int] = []
        
    private(set) var toolsCards: [HomeCardResponse] = []
    private(set) var campaignsCards: [HomeCardResponse] = []
        
    private var currentSegment: SegmentType = .tools
    
    private func fillCollectionView(isReloadAll: Bool) {
        self.homeCardsLoaded = true
        self.output.fillCollectionView(isReloadAll: isReloadAll)
    }
    
    func viewIsReady() {
        homeCardsService.delegate = self

        //handle public shared items save operation after login
        if let publicTokenToSave = storageVars.publicSharedItemsToken {
            savePublicSharedItems(with: publicTokenToSave)
            storageVars.publicSharedItemsToken = nil
        }
        
        getCampaignsScene {  [weak self] isCampaignsAvailable in
            guard let self = self else { return }
            if isCampaignsAvailable {
                self.output.showSegmentControl()
                self.getAllCardsForHomePage()
            } else {
                self.output.hideSegmentControl()
                self.callRemainingAPIs()
            }
        }
    }

    
    private func callRemainingAPIs() {
        FreeAppSpace.session.showFreeUpSpaceCard()
        FreeAppSpace.session.checkFreeUpSpace()
        getQuotaInfo()
        getAccountInfo()
        getPremiumCardInfo(loadStatus: .reloadAll)
        //        getBestScene { //v31 bestscene delete
        //            self.getAllCardsForHomePage()
        //        }
        getAllCardsForHomePage()
        getCampaignStatus()
        getActiveSubscriptionForBanner()
        getAvailableOffersForBanner()
        smartAlbumsManager.requestAllItems()
    }
    
    func needRefresh() {
        getCampaignsScene { [weak self] isCampaignsAvailable in
            guard let self = self else { return }
            if isCampaignsAvailable {
                self.output.showSegmentControl()
                self.getAllCardsForHomePage()
            } else {
                self.homeCardsLoaded = false
                self.output.hideSegmentControl()
                self.getCampaignStatus()
                self.getPremiumCardInfo(loadStatus: .reloadAll)
                self.getAllCardsForHomePage()
            }
        }
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
    
    func updateCurrentSegment(_ segment: SegmentType) {
            self.currentSegment = segment
        }
    
    private func getAllCardsForHomePage() {
        homeCardsService.all { [weak self] result in
            DispatchQueue.main.async {
                self?.output.stopRefresh()
                switch result {
                case .success(let response):
                   
//                    self?.output.didObtainHomeCards(response)
//                    self?.fillCollectionView(isReloadAll: true)
                    
                    self?.filterCardsData(cards: response)
                    
                    if let currentSegment = self?.currentSegment {
                                            self?.updateCollectionView(for: currentSegment)
                                        }
                    
                case .failed(let error):
                    DispatchQueue.toMain {
                        self?.output.didObtainError(with: error.description, isNeedStopRefresh: true)
                    }
                }
            }
        }
    }
    
    private func updateCollectionView(for segment: SegmentType) {
        self.currentSegment = segment
        print("⚠️⚠️", self.currentSegment)
        switch currentSegment {
        case .tools:
            self.output.updateCollectionView(with: toolsCards)
        case .campaigns:
            self.output.updateCollectionView(with: campaignsCards)
        }
    }

    
     func filterCardsData(cards: [HomeCardResponse]) {
        toolsCards = cards.filter {
            guard let type = $0.type else { return false }
            switch type {
            case .emptyStorage, .storageAlert, .latestUploads, .contactBackup, .autoSyncWatingForWifi, .autoSyncOff, .freeUpSpace, .instaPick,
                 .promotion, .divorce, .thingsDocument, .photoPrint, .discoverCard:
                return true
            default:
                return false
            }
        }
        
        campaignsCards = cards.filter {
            guard let type = $0.type else { return false }
            switch type {
            case .launchCampaign, .campaign, .newCampaign:
                return true
            default:
                return false
            }
        }
        
        print("⚠️ Tools Cards: \(toolsCards)")
        print("⚠️ Campaigns Cards: \(campaignsCards)")
    }
    
    private func getCampaignsScene(completion: @escaping (Bool) -> Void) {
        homeCardsService.getCampaigns { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                let isAvailable = !response.isEmpty
                completion(isAvailable)
            case .failed(let error):
                DispatchQueue.main.async {
                    self.output.didObtainError(with: error.localizedDescription, isNeedStopRefresh: false)
                }
                self.output.hideSegmentControl()
                completion(false)
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
    
    private func getBestScene(completion: @escaping () -> Void) {
        homeCardsService.getBestGroup { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                _ = response.map { burstGroup -> HomeCardResponse in
                    let homeCard = HomeCardResponse()
                    homeCard.id = burstGroup.id
                    homeCard.type = .discoverCard
                    let imageUrls = response.map { $0.coverPhoto?.metadata?.thumbnailMedium }.compactMap { $0 }
                    let burstGroupId = response.map { $0.id }.compactMap { $0 }
                  
                    let createdDate = response.map { $0.groupDate }.compactMap { $0 }
                    
                    self.output.didObtainHomeCardsBestScene(homeCard, imageUrls: imageUrls, createdDate: createdDate, groupId: burstGroupId)
                    return homeCard
                }
            case .failed(let error):
                DispatchQueue.main.async {
                    self.output.didObtainError(with: error.localizedDescription, isNeedStopRefresh: false)
                }
            }
            completion()
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
    
    func getActiveSubscriptionForBanner() {
        subscriptionsService.activeSubscriptions(
            success: { [weak self] response in
                guard let subscriptionsResponse = response as? ActiveSubscriptionResponse else {
                    return
                }
                let offersList = subscriptionsResponse.list
                DispatchQueue.main.async {
                    self?.isPaidPackage = self?.isPaidPackage(item: offersList) ?? false
                    self?.bannerCallMethodCount += 1
                    self?.setBannerPremiumOrHighlighted()
                }
            }, fail: { value in }, isLogin: false)
    }
    
    func getAvailableOffersForBanner() {
        accountService.availableOffersWithLanguage(affiliate: "") { [weak self] (result) in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    let convertedResponse = self?.packageService.convertToSubscriptionPlan(offers: response, accountType: .turkcell)
                    self?.getHighlightedPackage(offers: convertedResponse ?? [])
                }
            case .failed(_):
                break
            }
        }
    }
    
    func getHighlightedPackage(offers: [SubscriptionPlan]) {
        var packageName: String = ""
        for value in offers {
            let model = value.model as? PackageModelResponse
            if model?.highlighted == true {
                highlightedPackage = value
                packageName = model?.name ?? ""
            }
        }
        
        for(index, value) in offers.enumerated() {
            let model = value.model as? PackageModelResponse
            if model?.name == packageName {
                highlightedPackageIndex = index
            }
        }
        
        bannerCallMethodCount += 1
        setBannerPremiumOrHighlighted()
    }
    
    private func setBannerPremiumOrHighlighted() {
        if bannerCallMethodCount == 2 {
            bannerCallMethodCount = 0
            output.fillCollectionViewForHighlighted(isPaidPackage: isPaidPackage, offers: highlightedPackage, packageIndex: highlightedPackageIndex)
        }
    }
    
    private func isPaidPackage(item: [SubscriptionPlanBaseResponse]) -> Bool {
        var isPriceForPayed: Bool = false
        for value in item {
            let price = value.subscriptionPlanPrice ?? 0
            if price > 0 {
                isPriceForPayed = true
            }
        }
        return isPriceForPayed
    }
}

extension HomePageInteractor: HomeCardsServiceImpDelegte {
    
    func albumHiddenSuccessfully(_ successfully: Bool) {
        let message = successfully ? TextConstants.hideSingleAlbumSuccessPopupMessage : TextConstants.temporaryErrorOccurredTryAgainLater
        output.showSnackBarWith(message: message)
    }
    
    func needUpdateHomeScreen() {
        if !homeCardsLoaded {
            self.getAllCardsForHomePage()
        }
    }
    
    func showSpinner() {
        output.showSpinner()
    }
    
    func hideSpinner() {
        output.hideSpinner()
    }
}
