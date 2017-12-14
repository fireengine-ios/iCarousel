//
//  HomePageHomePageInteractor.swift
//  Depo
//
//  Created by AlexanderP on 22/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class HomePageInteractor: HomePageInteractorInput {

    weak var output: HomePageInteractorOutput!
    
    func homePagePresented(){
        FreeAppSpace.default.checkFreeAppSpace()
        SyncService.default.startSyncImmediately()
        SyncService.default.onLoginUser()
    }

}
