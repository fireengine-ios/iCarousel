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
        SyncServiceManager.shared.updateImmediately()
        
        CardsManager.default.startOperationWith(type: .contactBacupOld, allOperations: nil, completedOperations: nil)
        CardsManager.default.startOperationWith(type: .contactBacupEmpty, allOperations: nil, completedOperations: nil)
        
        CardsManager.default.startOperationWith(type: .freeAppSpaceLocalWarning, allOperations: nil, completedOperations: nil)
        CardsManager.default.startOperationWith(type: .freeAppSpaceCloudWarning, allOperations: nil, completedOperations: nil)
        CardsManager.default.startOperationWith(type: .emptyStorage, allOperations: nil, completedOperations: nil)
        CardsManager.default.startOperationWith(type: .collage, allOperations: nil, completedOperations: nil)
        CardsManager.default.startOperationWith(type: .albumCard, allOperations: nil, completedOperations: nil)
    }

}
