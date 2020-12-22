//
//  CreateStoryPreviewCreateStoryPreviyConfigurator.swift
//  Depo
//
//  Created by Oleg on 18/10/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class CreateStoryPreviewModuleConfigurator {

 func configure(viewController: CreateStoryPreviewViewController, story: PhotoStory, response: CreateStoryResponse) {

        let router = CreateStoryPreviewRouter()
        router.view = viewController
    
        let presenter = CreateStoryPreviewPresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = CreateStoryPreviewInteractor()
        interactor.output = presenter
        interactor.response = response
        interactor.story = story

        presenter.interactor = interactor
        viewController.output = presenter
    }
}
