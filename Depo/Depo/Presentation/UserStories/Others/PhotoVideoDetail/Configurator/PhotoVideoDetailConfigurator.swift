//
//  PhotoVideoDetailPhotoVideoDetailConfigurator.swift
//  Depo
//
//  Created by Oleg on 01/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class PhotoVideoDetailModuleConfigurator {

    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController,
                                                       photoVideoBottomBarConfig: EditingBarConfig,
                                                       documentsBottomBarConfig: EditingBarConfig,
                                                       selecetedItem: Item,
                                                       allItems: [Item],
                                                       hideActions: Bool = false) {
        if let viewController = viewInput as? PhotoVideoDetailViewController {
            configure(viewController: viewController, photoVideoBottomBarConfig: photoVideoBottomBarConfig, documentsBottomBarConfig: documentsBottomBarConfig, alertSheetExcludeTypes: [.delete],
                      photoDetailMoreMenu: ActionSheetPredetermendConfigs.photoVideoDetailActions,
                      selecetedItem: selecetedItem, allItems: allItems, hideActions: hideActions)
        }
    }

    func configureModuleFromAlbumForViewInput<UIViewController>(viewInput: UIViewController,
                                                                photoVideoBottomBarConfig: EditingBarConfig,
                                                                documentsBottomBarConfig: EditingBarConfig,
                                                                selecetedItem: Item,
                                                                allItems: [Item],
                                                                albumUUID: String,
                                                                albumItem: Item? = nil,
                                                                hideActions: Bool = false) {
        if let viewController = viewInput as? PhotoVideoDetailViewController {
            let interactor = PhotoVideoAlbumDetailInteractor()
            interactor.albumUUID = albumUUID
            configure(viewController: viewController,
                      photoVideoBottomBarConfig: photoVideoBottomBarConfig,
                      documentsBottomBarConfig: documentsBottomBarConfig,
                      interactor: interactor,
                      photoDetailMoreMenu: ActionSheetPredetermendConfigs.photoVideoDetailActions + [.delete],
                      selecetedItem: selecetedItem, allItems: allItems, albumItem: albumItem, hideActions: hideActions)
        }
    }
    
    func configureModuleFromFaceImageAlbumForViewInput<UIViewController>(viewInput: UIViewController,
                                                                photoVideoBottomBarConfig: EditingBarConfig,
                                                                documentsBottomBarConfig: EditingBarConfig,
                                                                selecetedItem: Item,
                                                                allItems: [Item],
                                                                albumUUID: String,
                                                                albumItem: Item? = nil,
                                                                hideActions: Bool = false) {
        if let viewController = viewInput as? PhotoVideoDetailViewController {
            let interactor = PhotoVideoAlbumDetailInteractor()
            interactor.albumUUID = albumUUID
            configure(viewController: viewController,
                      photoVideoBottomBarConfig: photoVideoBottomBarConfig,
                      documentsBottomBarConfig: documentsBottomBarConfig,
                      interactor: interactor,
                      photoDetailMoreMenu: ActionSheetPredetermendConfigs.photoVideoDetailActions + [.deleteFaceImage],
                      selecetedItem: selecetedItem, allItems: allItems, albumItem: albumItem, hideActions: hideActions)
        }
    }
    
    func configureModuleFromHiddenAlbumForViewInput<UIViewController>(viewInput: UIViewController,
                                                                      photoVideoBottomBarConfig: EditingBarConfig,
                                                                      documentsBottomBarConfig: EditingBarConfig,
                                                                      selecetedItem: Item,
                                                                      allItems: [Item],
                                                                      albumUUID: String,
                                                                      albumItem: Item? = nil,
                                                                      hideActions: Bool = false) {
        if let viewController = viewInput as? PhotoVideoDetailViewController {
            viewController.hideTreeDotButton = true
            
            let interactor = PhotoVideoAlbumDetailInteractor()
            interactor.albumUUID = albumUUID
            configure(viewController: viewController,
                      photoVideoBottomBarConfig: photoVideoBottomBarConfig,
                      documentsBottomBarConfig: documentsBottomBarConfig,
                      interactor: interactor,
                      photoDetailMoreMenu: ActionSheetPredetermendConfigs.hiddenDetailActions,
                      selecetedItem: selecetedItem, allItems: allItems, albumItem: albumItem, hideActions: hideActions)
        }
    }
    
    func configureModuleForHiddenViewInput<UIViewController>(viewInput: UIViewController,
                                                             photoVideoBottomBarConfig: EditingBarConfig,
                                                             documentsBottomBarConfig: EditingBarConfig,
                                                             selecetedItem: Item,
                                                             allItems: [Item],
                                                             hideActions: Bool = false) {
        if let viewController = viewInput as? PhotoVideoDetailViewController {
            viewController.hideTreeDotButton = true
            
            configure(viewController: viewController, photoVideoBottomBarConfig: photoVideoBottomBarConfig, documentsBottomBarConfig: documentsBottomBarConfig, alertSheetExcludeTypes: [.unhide,.delete],
                      photoDetailMoreMenu: ActionSheetPredetermendConfigs.hiddenDetailActions,
                      selecetedItem: selecetedItem, allItems: allItems, hideActions: hideActions)
        }
    }
    
    private func configure(viewController: PhotoVideoDetailViewController,
                           photoVideoBottomBarConfig: EditingBarConfig,
                           documentsBottomBarConfig: EditingBarConfig,
                           alertSheetConfig: AlertFilesActionsSheetInitialConfig? = nil,
                           alertSheetExcludeTypes: [ElementTypes] = [ElementTypes](),
                           interactor: PhotoVideoDetailInteractor = PhotoVideoDetailInteractor(),
                           photoDetailMoreMenu: [ElementTypes],
                           selecetedItem: Item,
                           allItems: [Item],
                           albumItem: Item? = nil,
                           hideActions: Bool) {
        let router = PhotoVideoDetailRouter()

        let presenter = PhotoVideoDetailPresenter()
        presenter.view = viewController
        presenter.router = router
        presenter.alertSheetExcludeTypes = alertSheetExcludeTypes
        
        if let albumItem = albumItem {
            presenter.item = albumItem
        }
        
        interactor.output = presenter
        interactor.photoVideoBottomBarConfig = photoVideoBottomBarConfig
        interactor.documentsBottomBarConfig = documentsBottomBarConfig
        
        interactor.moreMenuConfig = photoDetailMoreMenu
        
        //BotomBar Module Setup
        let bottomBarVCmodule = BottomSelectionTabBarModuleInitializer()
        let botvarBarVC = bottomBarVCmodule.setupModule(config: photoVideoBottomBarConfig, settablePresenter: BottomSelectionTabBarPresenter())
        viewController.editingTabBar = botvarBarVC
        viewController.hideActions = hideActions
        presenter.bottomBarPresenter = bottomBarVCmodule.presenter
        bottomBarVCmodule.presenter?.basePassingPresenter = presenter
        //--------------------
        //AlertSheetActions Module Setup
        let alertSheetModuleInitilizer = AlertFilesActionsSheetPresenterModuleInitialiser()
        let alertModulePresenter = alertSheetModuleInitilizer.createModule()
        presenter.alertSheetModule = alertModulePresenter
        
        alertModulePresenter.basePassingPresenter = presenter
        //-------------------
        presenter.interactor = interactor
        viewController.output = presenter
        
        interactor.onSelectItem(fileObject: selecetedItem, from: allItems)
        
    }

}
