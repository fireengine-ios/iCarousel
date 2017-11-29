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
        viewController.needShowTabBar = true
        let configurator = BaseFilesGreedModuleConfigurator()
        let bottomBarConfig = EditingBarConfig(elementsConfig: [.share, .download, .addToAlbum, .print, .removeFromAlbum],
                                               style: .default, tintColor: nil)
        
        let presentor = AlbumDetailPresenter()
        
        
        let interactor = AlbumDetailInteractor(remoteItems: AlbumDetailService(requestSize: 140))
        interactor.album = album
        
        configurator.configure(viewController: viewController, fileFilters: [.rootAlbum(album.uuid)],
                               bottomBarConfig: bottomBarConfig, router: AlbumDetailRouter(),
                               presenter: presentor, interactor: interactor,
                               alertSheetConfig: AlertFilesActionsSheetInitialConfig(initialTypes: [.shareAlbum, .download, .select],
                                                                                     selectionModeTypes: [.createStory, .delete]),
                               topBarConfig: nil)
        
        viewController.mainTitle = album.name
        
        return viewController
    }
    
}
