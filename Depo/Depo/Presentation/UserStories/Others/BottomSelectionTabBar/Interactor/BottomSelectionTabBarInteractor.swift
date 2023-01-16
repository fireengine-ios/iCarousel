//
//  BottomSelectionTabBarBottomSelectionTabBarInteractor.swift
//  Depo
//
//  Created by AlexanderP on 03/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class BottomSelectionTabBarInteractor: MoreFilesActionsInteractor, BottomSelectionTabBarInteractorInput {
    
    private var dataStorage: EditingBarConfig?
    private let queue = DispatchQueue(label: "currentBarcongfig.queue")
    
    typealias FailResponse = (_ value: ErrorResponse) -> Void
    
    var currentBarcongfig: EditingBarConfig? {
        set {
            queue.sync { [weak self] in
                self?.dataStorage = newValue
            }
        } get {
            var config: EditingBarConfig?
            queue.sync {
                config = self.dataStorage
            }
            return config
        }
    }
}
