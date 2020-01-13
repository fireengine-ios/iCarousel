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
                                                       bottomBarConfig: EditingBarConfig,
                                                       selecetedItem: Item,
                                                       allItems: [Item],
                                                       status: ItemStatus) {
        if let viewController = viewInput as? PhotoVideoDetailViewController {
            configure(viewController: viewController,
                      bottomBarConfig: bottomBarConfig,
                      alertSheetExcludeTypes: [.delete],
                      photoDetailMoreMenu: ActionSheetPredetermendConfigs.photoVideoDetailActions,
                      selecetedItem: selecetedItem,
                      allItems: allItems, status: status, viewType: .details)
        }
    }

    func configureModuleFromAlbumForViewInput<UIViewController>(viewInput: UIViewController,
                                                                bottomBarConfig: EditingBarConfig,
                                                                selecetedItem: Item,
                                                                allItems: [Item],
                                                                albumUUID: String,
                                                                albumItem: Item? = nil,
                                                                status: ItemStatus) {
        if let viewController = viewInput as? PhotoVideoDetailViewController {
            let interactor = PhotoVideoAlbumDetailInteractor()
            interactor.albumUUID = albumUUID
            configure(viewController: viewController,
                      bottomBarConfig: bottomBarConfig,
                      interactor: interactor,
                      photoDetailMoreMenu: ActionSheetPredetermendConfigs.photoVideoDetailActions + [.delete],
                      selecetedItem: selecetedItem, allItems: allItems, albumItem: albumItem,
                      status: status, viewType: .insideAlbum)
        }
    }
    
    func configureModuleFromFaceImageAlbumForViewInput<UIViewController>(viewInput: UIViewController,
                                                                bottomBarConfig: EditingBarConfig,
                                                                selecetedItem: Item,
                                                                allItems: [Item],
                                                                albumUUID: String,
                                                                albumItem: Item? = nil,
                                                                status: ItemStatus) {
        if let viewController = viewInput as? PhotoVideoDetailViewController {
            let interactor = PhotoVideoAlbumDetailInteractor()
            interactor.albumUUID = albumUUID
            configure(viewController: viewController,
                      bottomBarConfig: bottomBarConfig,
                      interactor: interactor,
                      photoDetailMoreMenu: ActionSheetPredetermendConfigs.photoVideoDetailActions + [.deleteFaceImage],
                      selecetedItem: selecetedItem, allItems: allItems, albumItem: albumItem,
                      status: status, viewType: .insideFIRAlbum)
        }
    }
    
    private func configure(viewController: PhotoVideoDetailViewController,
                           bottomBarConfig: EditingBarConfig,
                           alertSheetConfig: AlertFilesActionsSheetInitialConfig? = nil,
                           alertSheetExcludeTypes: [ElementTypes] = [ElementTypes](),
                           interactor: PhotoVideoDetailInteractor = PhotoVideoDetailInteractor(),
                           photoDetailMoreMenu: [ElementTypes],
                           selecetedItem: Item,
                           allItems: [Item],
                           albumItem: Item? = nil,
                           status: ItemStatus,
                           viewType: DetailViewType) {
        let router = PhotoVideoDetailRouter()

        let presenter = PhotoVideoDetailPresenter()
        presenter.view = viewController
        presenter.router = router
        presenter.alertSheetExcludeTypes = alertSheetExcludeTypes
        
        if status == .trashed {
            presenter.alertSheetExcludeTypes.append(.addToFavorites)
        }
        
        if let albumItem = albumItem {
            presenter.item = albumItem
        }
        
        interactor.output = presenter
        interactor.bottomBarConfig = bottomBarConfig
        interactor.status = status
        interactor.viewType = viewType
        interactor.moreMenuConfig = photoDetailMoreMenu
        
        //BotomBar Module Setup
        let bottomBarVCmodule = BottomSelectionTabBarModuleInitializer()
        let botvarBarVC = bottomBarVCmodule.setupModule(config: bottomBarConfig, settablePresenter: BottomSelectionTabBarPresenter())
        viewController.editingTabBar = botvarBarVC
        viewController.status = status
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
