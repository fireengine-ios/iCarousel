//
//  PhotoPrintConfigurator.swift
//  Depo
//
//  Created by Ozan Salman on 22.08.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

class PhotoPrintConfigurator {
    
    func configure(viewController: PhotoPrintViewController) {

        let router = PhotoPrintRouter()

        let presenter = PhotoPrintPresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = PhotoPrintInteractor()
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
    }
}
