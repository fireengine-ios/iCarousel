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
                                                       inputPresenter: LBAlbumLikePreviewSliderPresenter?,
                                                       peopleItem: PeopleItem? = nil,
                                                       moduleOutput: FaceImagePhotosModuleOutput?) {

        if let viewController = viewInput as? LBAlbumLikePreviewSliderViewController {
            configure(viewController: viewController, inputPresenter: inputPresenter, peopleItem: peopleItem, moduleOutput: moduleOutput)
        }
    }

    private func configure(viewController: LBAlbumLikePreviewSliderViewController,
                           inputPresenter: LBAlbumLikePreviewSliderPresenter?,
                           peopleItem: PeopleItem? = nil,
                           moduleOutput: FaceImagePhotosModuleOutput?) {

        let router = LBAlbumLikePreviewSliderRouter()

        var presenter: LBAlbumLikePreviewSliderPresenter
        
        if let unwrapedInputPresenter = inputPresenter {
            presenter = unwrapedInputPresenter
        } else {
            presenter = LBAlbumLikePreviewSliderPresenter()
        }
        
       
        presenter.view = viewController
        presenter.router = router

        let interactor: LBAlbumLikePreviewSliderInteractor
        if let peopleItem = peopleItem {
            interactor = PeopleAlbumSliderInteractor(peopleItem: peopleItem)
            
            let title = String(format: TextConstants.albumLikeSliderWithPerson,
                               peopleItem.name ?? TextConstants.faceImageThisPerson)
        } else {
            interactor = LBAlbumLikePreviewSliderInteractor()
        }
        
        interactor.output = presenter
        ItemOperationManager.default.startUpdateView(view: interactor)

        presenter.interactor = interactor
        viewController.output = presenter
        presenter.faceImagePhotosModuleOutput = moduleOutput
    }

}
