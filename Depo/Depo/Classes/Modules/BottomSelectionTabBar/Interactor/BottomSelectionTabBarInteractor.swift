//
//  BottomSelectionTabBarBottomSelectionTabBarInteractor.swift
//  Depo
//
//  Created by AlexanderP on 03/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class BottomSelectionTabBarInteractor: MoreFilesActionsInteractor, BottomSelectionTabBarInteractorInput {
    
//    weak var output: BottomSelectionTabBarInteractorOutput!
    private var fileService = WrapItemFileService()
    
    let dataStorage = BottomSelectionTabBarDataStorage()
    
    typealias FailResponse = (_ value: ErrorResponse) -> Swift.Void
    
    var currentBarcongfig: EditingBarConfig? {
        set {
            dataStorage.currentBarConfig = newValue
        } get {
            return dataStorage.currentBarConfig
        }
    }
}
