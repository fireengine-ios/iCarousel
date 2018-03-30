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
        
        homeCardsService.all { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let array):
                    CardsManager.default.startOperatonsForCardsResponces(cardsResponces: array)
                case .failed(let error):
                    UIApplication.showErrorAlert(message: error.localizedDescription)
                }
            }
        }
    }

}
