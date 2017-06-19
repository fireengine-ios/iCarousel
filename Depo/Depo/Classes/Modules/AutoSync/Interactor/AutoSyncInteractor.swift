//
//  AutoSyncAutoSyncInteractor.swift
//  Depo
//
//  Created by Oleg on 16/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class AutoSyncInteractor: AutoSyncInteractorInput {

    weak var output: AutoSyncInteractorOutput!
    var dataStorage = AutoSyncDataStorage()

    func prepareCellsModels(){
        output.preperedCellsModels(models: dataStorage.getAutoSyncModels())
    }
    
}
