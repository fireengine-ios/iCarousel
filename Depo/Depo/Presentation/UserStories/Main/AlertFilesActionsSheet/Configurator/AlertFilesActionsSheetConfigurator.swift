//
//  AlertFilesActionsSheetConfigurator.swift
//  Depo_LifeTech
//
//  Created by Aleksandr on 9/18/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

class AlertFilesActionsSheetConfigurator {
    
    func config(withPresenter presenter: AlertFilesActionsSheetPresenter) {
        let interactor = AlertFilesActionsSheetInteractor()
        interactor.output = presenter
        presenter.interactor = interactor
        
    }
    
}
