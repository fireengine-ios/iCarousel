//
//  UploadFromLifeBoxUploadFromLifeBoxConfigurator.swift
//  Depo
//
//  Created by Oleg on 01/12/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class UploadFromLifeBoxModuleConfigurator {

    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController) {
        if let viewController = viewInput as? UploadFromLifeBoxViewController {
            configure(viewController: viewController)
        }
    }

    private func configure(viewController: UploadFromLifeBoxViewController) {

        let router = UploadFromLifeBoxRouter()

        let presenter = UploadFromLifeBoxPresenter()
        presenter.view = viewController
        //presenter.router = router

        //let interactor = UploadFromLifeBoxInteractor(remoteItems: PhotoSelectionDataSource())
        //interactor.output = presenter

        //presenter.interactor = interactor
        viewController.output = presenter
    }
}
