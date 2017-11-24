//
//  CreateStoryPhotosOrderCreateStoryPhotosOrderConfigurator.swift
//  Depo
//
//  Created by Oleg on 03/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class CreateStoryPhotosOrderModuleConfigurator {

    func configure(viewController: CreateStoryPhotosOrderViewController, story: PhotoStory) {

        let router = CreateStoryPhotosOrderRouter()

        let presenter = CreateStoryPhotosOrderPresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = CreateStoryPhotosOrderInteractor()
        interactor.story = story
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
    }

}
