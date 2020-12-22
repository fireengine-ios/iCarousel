//
//  BottomSelectionTabBarBottomSelectionTabBarInteractor.swift
//  Depo
//
//  Created by AlexanderP on 03/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class BottomSelectionTabBarInteractor: MoreFilesActionsInteractor, BottomSelectionTabBarInteractorInput {
    
    let dataStorage = BottomSelectionTabBarDataStorage()
    
    typealias FailResponse = (_ value: ErrorResponse) -> Void
    
    var currentBarcongfig: EditingBarConfig? {
        set {
            dataStorage.currentBarConfig = newValue
        } get {
            return dataStorage.currentBarConfig
        }
    }
}
