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
    
    func homePagePresented() {
        FreeAppSpace.default.checkFreeAppSpace()
        SyncServiceManager.shared.updateImmediately()
        PushNotificationService.shared.openActionScreen()
        
        getAllCardsForHomePage()
        
        showQuotaPopUpIfNeed()
    }
    
    func needRefresh() {
        getAllCardsForHomePage()
    }
    
    func getAllCardsForHomePage() {
        homeCardsService.all { [weak self] result in
            DispatchQueue.main.async {
                self?.output.stopRefresh()
                switch result {
                case .success(let array):
                    CardsManager.default.startOperatonsForCardsResponces(cardsResponces: array)
                case .failed(let error):
                    UIApplication.showErrorAlert(message: error.description)
                }
            }
        }
    }
    
    func showQuotaPopUpIfNeed() {
        let storageVars: StorageVars = factory.resolve()
        
        let isFirstTime = !storageVars.homePageFirstTimeLogin
        if isFirstTime {
            storageVars.homePageFirstTimeLogin = true
        }
        AccountService().quotaInfo(success: { [weak self] response in
            if let qresponce = response as? QuotaInfoResponse {
                guard let quotaBytes = qresponce.bytes, let usedBytes = qresponce.bytesUsed else { return }
                let usagePercent = Float(usedBytes) / Float(quotaBytes)
                var viewForPresent: UIViewController? = nil
                
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
                    self?.output.needPresentPopUp(popUpView: popUpView)
                }
                
            }
            
            
            }, fail: { error in
                //error handling not need
                
        })
    }

}
