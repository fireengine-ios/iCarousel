//
//  ImportPhotosConfigurator.swift
//  Depo
//
//  Created by Maksim Rahleev on 04.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

class ImportPhotosConfigurator {
    
    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController) {
        
        if let viewController = viewInput as? ImportPhotosViewController {
            configure(viewController: viewController)
        }
    }
    
    private func configure(viewController: ImportPhotosViewController) {
        // Facebook configuration
        let fbRouter = ImportFromFBRouter()
        
        let fbPresenter = ImportFromFBPresenter()
        fbPresenter.view = viewController
        fbPresenter.router = fbRouter
        
        let fbInteractor = ImportFromFBInteractor()
        fbInteractor.output = fbPresenter
        
        fbPresenter.interactor = fbInteractor
        viewController.fbOutput = fbPresenter
        
        // Dropbox configuration
        let dbRouter = ImportFromDropboxRouter()
        
        let dbPresenter = ImportFromDropboxPresenter()
        dbPresenter.view = viewController
        dbPresenter.router = dbRouter
        
        let dbInteractor = ImportFromDropboxInteractor()
        dbInteractor.output = dbPresenter
        
        dbPresenter.interactor = dbInteractor
        viewController.dbOutput = dbPresenter
    }
}
