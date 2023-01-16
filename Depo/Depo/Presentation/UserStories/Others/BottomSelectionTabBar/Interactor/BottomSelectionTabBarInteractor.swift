//
//  BottomSelectionTabBarBottomSelectionTabBarInteractor.swift
//  Depo
//
//  Created by AlexanderP on 03/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class BottomSelectionTabBarInteractor: MoreFilesActionsInteractor, BottomSelectionTabBarInteractorInput {
    
    private var dataStorage: EditingBarConfig?
    
    typealias FailResponse = (_ value: ErrorResponse) -> Void
    
    var currentBarcongfig: EditingBarConfig? {
        set {
            dataStorage = newValue
        } get {
            return dataStorage
        }
    }
}
