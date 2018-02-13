//
//  FaceImageAddNameConfigurator.swift
//  Depo
//
//  Created by Harhun Brothers on 07.02.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

final class FaceImageAddNameConfigurator {
    func configure(viewController: FaceImageAddNameViewController, item: WrapData, moduleOutput: FaceImagePhotosModuleOutput?) {
        let router = FaceImageAddNameRouter()
        
        let presenter = FaceImageAddNamePresenter()
                
        presenter.view = viewController
        presenter.router = router
        presenter.faceImagePhotosmoduleOutput = moduleOutput
        
        let interactor = FaceImageAddNameInteractor(remoteItems: PeopleItemsService(requestSize: 100))
        interactor.output = presenter
        
        presenter.interactor = interactor
        viewController.output = presenter
        
        viewController.mainTitle = TextConstants.faceImageAddName
        presenter.currentItem = item
    }
}
