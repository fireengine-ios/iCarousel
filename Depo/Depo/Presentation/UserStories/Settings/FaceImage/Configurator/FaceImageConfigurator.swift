//
//  FaceImageConfigurator.swift
//  Depo
//
//  Created by Tsimafei Harhun on 25.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class FaceImageConfigurator {
    
    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController) {
        
        if let viewController = viewInput as? FaceImageViewController2 {
            configure(viewController: viewController)
        }
    }
    
    private func configure(viewController: FaceImageViewController2) {
        
        let router = FaceImageRouter()
        
        let presenter = FaceImagePresenter()
        presenter.view = viewController
        presenter.router = router
        
        let interactor = FaceImageInteractor()
        interactor.output = presenter
        
        presenter.interactor = interactor
        viewController.output = presenter
    }
    
}
