//
//  AutoSyncAutoSyncPresenter.swift
//  Depo
//
//  Created by Oleg on 16/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class AutoSyncPresenter: AutoSyncModuleInput, AutoSyncViewOutput, AutoSyncInteractorOutput {

    weak var view: AutoSyncViewInput!
    var interactor: AutoSyncInteractorInput!
    var router: AutoSyncRouterInput!

    func viewIsReady() {
        interactor.prepareCellsModels()
    }
    
    func preperedCellsModels(models:[AutoSyncModel]){
        view.preperedCellsModels(models: models)
    }
}
