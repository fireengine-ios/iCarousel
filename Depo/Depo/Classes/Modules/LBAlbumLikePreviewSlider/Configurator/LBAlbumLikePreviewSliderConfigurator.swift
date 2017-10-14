//
//  LBAlbumLikePreviewSliderLBAlbumLikePreviewSliderConfigurator.swift
//  Depo
//
//  Created by AlexanderP on 21/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class LBAlbumLikePreviewSliderModuleConfigurator {

    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController,
                                     inputPresenter: LBAlbumLikePreviewSliderPresenter?) {

        if let viewController = viewInput as? LBAlbumLikePreviewSliderViewController {
            configure(viewController: viewController, inputPresenter: inputPresenter)
        }
    }

    private func configure(viewController: LBAlbumLikePreviewSliderViewController,
                           inputPresenter: LBAlbumLikePreviewSliderPresenter?) {

        let router = LBAlbumLikePreviewSliderRouter()

        var presenter: LBAlbumLikePreviewSliderPresenter
        
        if let unwrapedInputPresenter = inputPresenter {
            presenter = unwrapedInputPresenter
        } else {
            presenter = LBAlbumLikePreviewSliderPresenter()
        }
        
       
        presenter.view = viewController
        presenter.router = router

        let interactor = LBAlbumLikePreviewSliderInteractor()
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
    }

}
