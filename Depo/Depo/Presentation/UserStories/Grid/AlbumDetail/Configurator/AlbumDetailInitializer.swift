//
//  AlbumDetailAlbumDetailInitializer.swift
//  Depo
//
//  Created by Oleg on 24/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

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
        
        let configurator = BaseFilesGreedModuleConfigurator()
        let elementsConfig: [ElementTypes]
        
        switch status {
        case .hidden:
            elementsConfig = [.unhideAlbumItems, .moveToTrash]
        case .trashed:
            elementsConfig = [.restore, .delete]
        default:
            elementsConfig = [.share, .download, .addToAlbum, .hide, .moveToTrash]
        }
        
        let bottomBarConfig = EditingBarConfig(elementsConfig: elementsConfig,
                                                      style: .default, tintColor: nil)
        
        let presenter = SubscribedAlbumDetailPresenter()
        presenter.moduleOutput = moduleOutput
        
        let interactor = AlbumDetailInteractor(remoteItems: AlbumDetailService(requestSize: 140))
        interactor.album = album
        
        // FIXME: need to change folder property to uuid in base class
        let item = Item(imageData: Data()) /// some empty item to pass uuid
        item.uuid = album.uuid
        interactor.folder = item
        
        viewController.parentUUID = album.uuid
        
        let gridListTopBarConfig = GridListTopBarConfig(
            defaultGridListViewtype: type,
            availableSortTypes: baseSortTypes,
            defaultSortType: .TimeNewOld,
            availableFilter: false,
            showGridListButton: false
        )
        
        let alertFilesActionsTypes: [ElementTypes]
        let selectionModeTypes: [ElementTypes]
        
        switch status {
        case .hidden:
            alertFilesActionsTypes = [.unhide, .moveToTrash]
            selectionModeTypes = [.unhide, .moveToTrash]
        case .trashed:
            alertFilesActionsTypes = [.restore, .delete]
            selectionModeTypes = [.restore, .delete]
        default:
            if Device.isTurkishLocale {
                selectionModeTypes = [.createStory, .print, .removeFromAlbum]
            } else {
                selectionModeTypes = [.createStory, .removeFromAlbum]
            }
            alertFilesActionsTypes = [.shareAlbum, .download, .completelyMoveToTrash, .removeAlbum, .albumDetails, .hideAlbums, .select]
        }
        
        let alertSheetConfig = AlertFilesActionsSheetInitialConfig(initialTypes: alertFilesActionsTypes,
                                                                   selectionModeTypes: selectionModeTypes)
        
        configurator.configure(viewController: viewController,
                               fileFilters: [.rootAlbum(album.uuid), .localStatus(.nonLocal)],
                               bottomBarConfig: bottomBarConfig,
                               router: AlbumDetailRouter(),
                               presenter: presenter,
                               interactor: interactor,
                               alertSheetConfig: alertSheetConfig,
                               topBarConfig: gridListTopBarConfig)
        
        viewController.mainTitle = album.name ?? ""
        
        return viewController
    }
}
