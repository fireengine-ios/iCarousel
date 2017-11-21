//
//  AlertFilesActionsSheetPresenterModuleInitialiser.swift
//  Depo_LifeTech
//
//  Created by Aleksandr on 9/18/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

class AlertFilesActionsSheetPresenterModuleInitialiser {
    func createModule() -> AlertFilesActionsSheetPresenter {
        let presenter = AlertFilesActionsSheetPresenter()
        let configurator = AlertFilesActionsSheetConfigurator()
        configurator.config(withPresenter: presenter)
        
        return presenter
    }
}
