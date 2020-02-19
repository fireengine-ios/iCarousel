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
                                                       presenter: PhotoVideoDetailPresenter,
                                                       moduleOutput: PhotoVideoDetailModuleOutput? = nil,
                                                       bottomBarConfig: EditingBarConfig,
                                                       selecetedItem: Item,
                                                       allItems: [Item],
                                                       status: ItemStatus,
                                                       canLoadMoreItems: Bool) {
        if let viewController = viewInput as? PhotoVideoDetailViewController {
            configure(viewController: viewController,
                      presenter: presenter,
                      moduleOutput: moduleOutput,
                      bottomBarConfig: bottomBarConfig,
                      alertSheetExcludeTypes: [.moveToTrash],
                      photoDetailMoreMenu: ActionSheetPredetermendConfigs.photoVideoDetailActions,
                      selecetedItem: selecetedItem,
                      allItems: allItems, status: status, viewType: .details,
                      canLoadMoreItems: canLoadMoreItems)
        }
    }

    func configureModuleFromAlbumForViewInput<UIViewController>(viewInput: UIViewController,
                                                                presenter: PhotoVideoDetailPresenter,
                                                                moduleOutput: PhotoVideoDetailModuleOutput? = nil,
                                                                bottomBarConfig: EditingBarConfig,
                                                                selecetedItem: Item,
                                                                allItems: [Item],
                                                                albumUUID: String,
                                                                albumItem: Item? = nil,
                                                                status: ItemStatus) {
        if let viewController = viewInput as? PhotoVideoDetailViewController {
            let interactor = PhotoVideoDetailInteractor()
            interactor.albumUUID = albumUUID
            configure(viewController: viewController,
                      presenter: presenter,
                      moduleOutput: moduleOutput,
                      bottomBarConfig: bottomBarConfig,
                      interactor: interactor,
                      photoDetailMoreMenu: ActionSheetPredetermendConfigs.photoVideoDetailActions + [.moveToTrash],
                      selecetedItem: selecetedItem, allItems: allItems, albumItem: albumItem,
                      status: status, viewType: .insideAlbum,
                      canLoadMoreItems: true)
        }
    }
    
    func configureModuleFromFaceImageAlbumForViewInput<UIViewController>(viewInput: UIViewController,
                                                                         presenter: PhotoVideoDetailPresenter,
                                                                         moduleOutput: PhotoVideoDetailModuleOutput? = nil,
                                                                         bottomBarConfig: EditingBarConfig,
                                                                         selecetedItem: Item,
                                                                         allItems: [Item],
                                                                         albumUUID: String,
                                                                         albumItem: Item? = nil,
                                                                         status: ItemStatus) {
        if let viewController = viewInput as? PhotoVideoDetailViewController {
            let interactor = PhotoVideoDetailInteractor()
            interactor.albumUUID = albumUUID
            configure(viewController: viewController,
                      presenter: presenter,
                      moduleOutput: moduleOutput,
                      bottomBarConfig: bottomBarConfig,
                      interactor: interactor,
                      photoDetailMoreMenu: ActionSheetPredetermendConfigs.photoVideoDetailActions + [.moveToTrash],
                      selecetedItem: selecetedItem, allItems: allItems, albumItem: albumItem,
                      status: status, viewType: .insideFIRAlbum,
                      canLoadMoreItems: true)
        }
    }
    
    private func configure(viewController: PhotoVideoDetailViewController,
                           presenter: PhotoVideoDetailPresenter,
                           moduleOutput: PhotoVideoDetailModuleOutput? = nil,
                           bottomBarConfig: EditingBarConfig,
                           alertSheetConfig: AlertFilesActionsSheetInitialConfig? = nil,
                           alertSheetExcludeTypes: [ElementTypes] = [ElementTypes](),
                           interactor: PhotoVideoDetailInteractor = PhotoVideoDetailInteractor(),
                           photoDetailMoreMenu: [ElementTypes],
                           selecetedItem: Item,
                           allItems: [Item],
                           albumItem: Item? = nil,
                           status: ItemStatus,
                           viewType: DetailViewType,
                           canLoadMoreItems: Bool) {
        let router = PhotoVideoDetailRouter()

        presenter.view = viewController
        presenter.router = router
        presenter.alertSheetExcludeTypes = alertSheetExcludeTypes
        presenter.moduleOutput = moduleOutput
        presenter.canLoadMoreItems = canLoadMoreItems
        
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
