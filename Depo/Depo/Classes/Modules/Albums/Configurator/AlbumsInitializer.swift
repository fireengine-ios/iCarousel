//
//  AlbumsAlbumsInitializer.swift
//  Depo
//
//  Created by Oleg on 23/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class AlbumsModuleInitializer: NSObject {

    class func initializeAlbumsController(with nibName:String) -> BaseFilesGreedChildrenViewController {
        let viewController = BaseFilesGreedChildrenViewController(nibName: nibName, bundle: nil)
        let configurator = BaseFilesGreedModuleConfigurator()
        let bottomBarConfig = EditingBarConfig(elementsConfig: [.share,.delete],
                                               style: .default, tintColor: nil)
        
        let presentor = AlbumsPresenter()
        
        
        let interactor = AlbumsInteractor(remoteItems: AlbumService(requestSize: 9999))
        
        configurator.configure(viewController: viewController,
                               bottomBarConfig: bottomBarConfig, router: AlbumsRouter(),
                               presenter: presentor, interactor: interactor,
                               alertSheetConfig: AlertFilesActionsSheetInitialConfig(initialTypes: [.select, .selectAll],
                                                                                     selectionModeTypes: [.albumDetails]))
        
        viewController.mainTitle = TextConstants.albumsTitle
        
        return viewController
    }
    
    class func initializeSelectAlbumsController(with nibName:String, photos:[BaseDataSourceItem]) -> AlbumSelectionViewController {
        let viewController = AlbumSelectionViewController(nibName: nibName, bundle: nil)
        let configurator = BaseFilesGreedModuleConfigurator()
        let bottomBarConfig = EditingBarConfig(elementsConfig: [.share,.delete],
                                               style: .default, tintColor: nil)
        
        let presentor = AlbumSelectionPresenter()
        
        
        let interactor = AlbumsInteractor(remoteItems: AlbumService(requestSize: 9999))
        interactor.photos = photos
        
        configurator.configure(viewController: viewController,
                               bottomBarConfig: bottomBarConfig, router: AlbumsRouter(),
                               presenter: presentor, interactor: interactor,
                               alertSheetConfig: AlertFilesActionsSheetInitialConfig(initialTypes: [],
                                                                                     selectionModeTypes: []))
        
        viewController.mainTitle = TextConstants.albumsTitle
        
        return viewController
    }

}
