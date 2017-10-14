//
//  SearchViewConfigurator.swift
//  Depo
//
//  Created by Максим Деханов on 10.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

class SearchViewConfigurator {
    func configure(viewController: SearchViewController, remoteServices: RemoteSearchService) {
        let router = SeacrhViewRouter()
        
        let presenter = SearchViewPresenter()
        
        presenter.view = viewController
        presenter.router = router
        
        let interactor = SearchViewInteractor(remoteItems: remoteServices)
        interactor.output = presenter
        
        presenter.interactor = interactor
        viewController.output = presenter
    }
}
