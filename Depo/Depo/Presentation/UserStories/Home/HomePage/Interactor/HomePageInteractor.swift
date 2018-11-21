//
//  HomePageHomePageInteractor.swift
//  Depo
//
//  Created by AlexanderP on 22/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//


class HomePageInteractor: HomePageInteractorInput {

    weak var output: HomePageInteractorOutput!
    
    private lazy var homeCardsService: HomeCardsService = HomeCardsServiceImp()
    private(set) var homeCardsLoaded = false
    private lazy var analyticsService: AnalyticsService = factory.resolve()

    func homePagePresented() {
        FreeAppSpace.default.checkFreeAppSpace()
        setupAutoSyncTriggering()
        PushNotificationService.shared.openActionScreen()
        
        getPremiumCardInfo(isRefresh: false)
        getAllCardsForHomePage()
    }
    
    func trackScreen() {
        analyticsService.logScreen(screen: .homePage)
        analyticsService.trackDimentionsEveryClickGA(screen: .homePage)
    }
    
    private func setupAutoSyncTriggering() {
        SyncServiceManager.shared.setupAutosync()
        SyncServiceManager.shared.updateImmediately()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(checkAutoSync),
                                               name: .UIApplicationWillEnterForeground,
                                               object: nil)
    }
    
    @objc private func checkAutoSync() {
        SyncServiceManager.shared.updateImmediately()
    }
    
    func needRefresh() {
        homeCardsLoaded = false
        getAllCardsForHomePage()
        getPremiumCardInfo(isRefresh: true)
    }
    
    func getAllCardsForHomePage() {
        homeCardsService.all { [weak self] result in
            DispatchQueue.main.async {
                self?.output.stopRefresh()
                switch result {
                case .success(let array):
                    self?.homeCardsLoaded = true
                    CardsManager.default.startOperatonsForCardsResponces(cardsResponces: array)                    
                case .failed(let error):
                    UIApplication.showErrorAlert(message: error.description)
                }
            }
        }
    }

    func updateUserAuthority(_ isFirstAppear: Bool) {
        if !isFirstAppear {
            getPremiumCardInfo(isRefresh: true)
        }
    }

    private func getPremiumCardInfo(isRefresh: Bool) {
        let authorityStorage: AuthorityStorage = factory.resolve()
        AccountService().permissions { response in
            switch response {
            case .success(let result):
                authorityStorage.refrashStatus(premium: result.hasPermissionFor(.premiumUser),
                                            dublicates: result.hasPermissionFor(.deleteDublicate),
                                                 faces: result.hasPermissionFor(.faceRecognition))
                isRefresh ? CardsManager.default.refreshPremiumCard() : CardsManager.default.startPremiumCard()
            case .failed(_):
                isRefresh ? CardsManager.default.refreshPremiumCard() : CardsManager.default.startPremiumCard()
            }
        }
    }
    
    func needCheckQuota() {
        showQuotaPopUpIfNeed()
    }
    
    func showQuotaPopUpIfNeed() {
        let storageVars: StorageVars = factory.resolve()
        
        let isFirstTime = !storageVars.homePageFirstTimeLogin
        if isFirstTime {
            storageVars.homePageFirstTimeLogin = true
        }
        AccountService().quotaInfo(success: { [weak self] response in
            DispatchQueue.toMain {
                if let qresponce = response as? QuotaInfoResponse {
                    guard let quotaBytes = qresponce.bytes, let usedBytes = qresponce.bytesUsed else { return }
                    let usagePercent = Float(usedBytes) / Float(quotaBytes)
                    var viewForPresent: UIViewController? = nil
                    self?.trackQuota(quotaPercentage: usagePercent)
                    if isFirstTime {
                        if 0.8 <= usagePercent && usagePercent < 0.9 {
                            viewForPresent = LargeFullOfQuotaPopUp.popUp(type: .LargeFullOfQuotaPopUpType80)
                        }
                        else if 0.9 <= usagePercent && usagePercent < 1.0 {
                            viewForPresent = LargeFullOfQuotaPopUp.popUp(type: .LargeFullOfQuotaPopUpType90)
                        }
                        else if usagePercent >= 1.0 {
                            viewForPresent = LargeFullOfQuotaPopUp.popUp(type: .LargeFullOfQuotaPopUpType100)
                        }
                    } else if usagePercent >= 1.0{
                        viewForPresent = SmallFullOfQuotaPopUp.popUp()
                    }
                    
                    if let popUpView = viewForPresent {
                        
                        RouterVC().tabBarVC?.present(popUpView, animated: true, completion: nil)
//                        self?.output.needPresentPopUp(popUpView: popUpView)
                    }
                    
                }
            }
            
            }, fail: { error in
                //error handling not need
                
        })
    }

    func trackQuota(quotaPercentage: Float) {
        var quotaUsed: Int = 80
        if 0.8 <= quotaPercentage && quotaPercentage < 0.9 {
            quotaUsed = 80
        } else if 0.9 <= quotaPercentage && quotaPercentage < 0.95 {
            quotaUsed = 90
        } else if 0.95 <= quotaPercentage && quotaPercentage < 1.0 {
            quotaUsed = 95
        } else if quotaPercentage >= 1.0 {
            quotaUsed = 100
        } else {
            return
        }
        analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .quota, eventLabel: .quotaUsed(quotaUsed))
    }
    
}
