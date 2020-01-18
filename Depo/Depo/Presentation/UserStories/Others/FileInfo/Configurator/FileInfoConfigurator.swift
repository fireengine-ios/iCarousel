//
//  FileInfoFileInfoConfigurator.swift
//  Depo
//
//  Created by Oleg on 18/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class FileInfoModuleConfigurator {

    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController, item: BaseDataSourceItem, moduleOutput: FileInfoModuleOutput?) {

        if let viewController = viewInput as? FileInfoViewController {
            configure(viewController: viewController, item: item, moduleOutput: moduleOutput)
        }
    }

    private func configure(viewController: FileInfoViewController, item: BaseDataSourceItem, moduleOutput: FileInfoModuleOutput?) {

        let router = FileInfoRouter()

        let presenter = FileInfoPresenter()
        presenter.view = viewController
        presenter.router = router
        presenter.fileInfoModuleOutput = moduleOutput

        let interactor = FileInfoInteractor()
        interactor.output = presenter
        interactor.item = item

        presenter.interactor = interactor
        viewController.output = presenter
        
        viewController.interactor = interactor
    }

}
