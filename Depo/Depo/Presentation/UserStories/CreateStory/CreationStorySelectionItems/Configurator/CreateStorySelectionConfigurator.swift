//
//  CreateStorySelectionConfigurator.swift
//  Depo
//
//  Created by Oleg on 02/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class CreateStorySelectionConfigurator: BaseFilesGreedModuleConfigurator {

    func configure(viewController: BaseFilesGreedViewController, remoteServices: RemoteItemsService,
                   filters: [GeneralFilesFiltrationType]?, story: PhotoStory) {
        
        let router = CreateStorySelectionRouter()
        
        var presenter: BaseFilesGreedPresenter?
        if remoteServices is PhotoAndVideoService {
            presenter = CreateStoryPhotoSelectionPresenter()
        } else {
            presenter = CreateStoryAudioSelectionPresenter()
        }

        if let unwrapedFilters = filters {
            presenter?.filters = unwrapedFilters
        }
        
        presenter!.view = viewController
        presenter!.router = router
        presenter!.sortedRule = .metaDataTimeUp
        
        let interactor: CreateStorySelectionInteractor?
        if remoteServices is PhotoAndVideoService {
            interactor = CreateStorySelectionPhotoInteractor(remoteItems: remoteServices)
        } else {
            interactor = CreateStorySelectionInteractor(remoteItems: remoteServices)
        }
        interactor?.output = presenter
        interactor?.photoStory = story
        interactor?.originalFilters = filters
        
        presenter!.interactor = interactor
        viewController.output = presenter
    }

}
