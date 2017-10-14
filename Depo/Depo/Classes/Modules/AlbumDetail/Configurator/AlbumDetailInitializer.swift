//
//  AlbumDetailAlbumDetailInitializer.swift
//  Depo
//
//  Created by Oleg on 24/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class AlbumDetailModuleInitializer: NSObject {
    
    //Connect with object on storyboard
    class func initializeAlbumDetailController(with nibName:String, album: AlbumItem) -> AlbumDetailViewController {
        let viewController = AlbumDetailViewController(nibName: nibName, bundle: nil)
        let configurator = BaseFilesGreedModuleConfigurator()
        let bottomBarConfig = EditingBarConfig(elementsConfig: [.share, .download, .addToAlbum, .sync, .removeFromAlbum],
                                               style: .default, tintColor: nil)
        
        let presentor = AlbumDetailPresenter()
        
        
        let interactor = AlbumDetailInteractor(remoteItems: AlbumDetailService(requestSize: 9999))
        interactor.album = album
        
        configurator.configure(viewController: viewController,
                               bottomBarConfig: bottomBarConfig, router: BaseFilesGreedRouter(),
                               presenter: presentor, interactor: interactor,
                               alertSheetConfig: AlertFilesActionsSheetInitialConfig(initialTypes: [],
                                                                                     selectionModeTypes: []))
        
        viewController.mainTitle = album.name
        
        return viewController
    }
    
}
