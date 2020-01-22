//
//  AlbumDetailAlbumDetailInitializer.swift
//  Depo
//
//  Created by Oleg on 24/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

enum UniversalViewType {
    case bottomBar
    case actionSheet
    case selectionMode
}

class AlbumDetailModuleInitializer: NSObject {
    
    static var baseSortTypes: [MoreActionsConfig.SortRullesType] {
        return [.AlphaBetricAZ, .AlphaBetricZA, .TimeNewOld, .TimeOldNew, .Largest, .Smallest]
    }
    
    //Connect with object on storyboard
    class func initializeAlbumDetailController(with nibName: String, album: AlbumItem, type: MoreActionsConfig.ViewType, status: ItemStatus, moduleOutput: BaseFilesGreedModuleOutput?) -> AlbumDetailViewController {
        let viewController = AlbumDetailViewController(nibName: nibName, bundle: nil)
        viewController.album = album
        viewController.status = status
        viewController.needToShowTabBar = !status.isContained(in: [.hidden, .trashed])
        viewController.floatingButtonsArray.append(contentsOf: [.takePhoto, .upload, .uploadFromLifebox])
        viewController.scrollablePopUpView.addPermittedPopUpViewTypes(types: [.sync, .upload])
        viewController.scrollablePopUpView.isEnable = true
        viewController.mainTitle = album.name ?? ""
        viewController.parentUUID = album.uuid

        let elementsConfig = ElementTypes.albumElementsConfig(for: status, viewType: .bottomBar)
        let bottomBarConfig = EditingBarConfig(elementsConfig: elementsConfig, style: .default, tintColor: nil)
        
        let presenter = SubscribedAlbumDetailPresenter()
        presenter.moduleOutput = moduleOutput
        presenter.albumDetailModuleOutput = moduleOutput as? AlbumDetailModuleOutput
        
        let interactor = AlbumDetailInteractor(remoteItems: AlbumDetailService(requestSize: 140))
        interactor.album = album
        
        // FIXME: need to change folder property to uuid in base class
        let item = Item(imageData: Data(), isLocal: true) /// some empty item to pass uuid
        item.uuid = album.uuid
        interactor.folder = item
        interactor.parent = album
        
        let gridListTopBarConfig = GridListTopBarConfig(
            defaultGridListViewtype: type,
            availableSortTypes: baseSortTypes,
            defaultSortType: .TimeNewOld,
            availableFilter: false,
            showGridListButton: false
        )

        let alertFilesActionsTypes = ElementTypes.albumElementsConfig(for: status, viewType: .actionSheet)
        let selectionModeTypes = ElementTypes.albumElementsConfig(for: status, viewType: .selectionMode)
        let alertSheetConfig = AlertFilesActionsSheetInitialConfig(initialTypes: alertFilesActionsTypes,
                                                                   selectionModeTypes: selectionModeTypes)
        
        let configurator = BaseFilesGreedModuleConfigurator()
        configurator.configure(viewController: viewController,
                               fileFilters: [.rootAlbum(album.uuid), .localStatus(.nonLocal)],
                               bottomBarConfig: bottomBarConfig,
                               router: AlbumDetailRouter(),
                               presenter: presenter,
                               interactor: interactor,
                               alertSheetConfig: alertSheetConfig,
                               topBarConfig: gridListTopBarConfig)
        return viewController
    }
}
