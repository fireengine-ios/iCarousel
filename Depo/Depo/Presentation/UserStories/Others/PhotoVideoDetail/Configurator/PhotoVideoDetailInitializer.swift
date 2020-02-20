//
//  PhotoVideoDetailPhotoVideoDetailInitializer.swift
//  Depo
//
//  Created by Oleg on 01/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

enum DetailViewType {
    case details
    case insideAlbum
    case insideFIRAlbum
}

typealias PhotoVideoDetailModule = (controller: PhotoVideoDetailViewController, moduleInput: PhotoVideoDetailModuleInput)

class PhotoVideoDetailModuleInitializer: NSObject {

    class func initializeViewController(with nibName: String, moduleOutput: PhotoVideoDetailModuleOutput? = nil, selectedItem: Item, allItems: [Item], status: ItemStatus, canLoadMoreItems: Bool) -> PhotoVideoDetailModule {
        let elementsConfig = ElementTypes.detailsElementsConfig(for: selectedItem, status: status, viewType: .details)
        
        let bottomBarConfig = EditingBarConfig(elementsConfig: elementsConfig,
                                               style: .blackOpaque, tintColor: nil)
        
        let viewController = PhotoVideoDetailViewController(nibName: nibName, bundle: nil)
        let configurator = PhotoVideoDetailModuleConfigurator()
        let presenter = PhotoVideoDetailPresenter()
        configurator.configureModuleForViewInput(viewInput: viewController,
                                                 presenter: presenter,
                                                 moduleOutput: moduleOutput,
                                                 bottomBarConfig: bottomBarConfig,
                                                 selecetedItem: selectedItem,
                                                 allItems: allItems,
                                                 status: status,
                                                 canLoadMoreItems: canLoadMoreItems)
        return (viewController, presenter)
    }
    
    class func initializeAlbumViewController(with nibName: String, moduleOutput: PhotoVideoDetailModuleOutput? = nil, selectedItem: Item, allItems: [Item], albumUUID: String, status: ItemStatus) -> PhotoVideoDetailModule {
        let elementsConfig = ElementTypes.detailsElementsConfig(for: selectedItem, status: status, viewType: .insideAlbum)
        
        let bottomBarConfig = EditingBarConfig(elementsConfig: elementsConfig,
                                               style: .blackOpaque, tintColor: nil)
        
        let viewController = PhotoVideoDetailViewController(nibName: nibName, bundle: nil)
        let configurator = PhotoVideoDetailModuleConfigurator()
        let presenter = PhotoVideoDetailPresenter()
        configurator.configureModuleFromAlbumForViewInput(viewInput: viewController,
                                                          presenter: presenter,
                                                          moduleOutput: moduleOutput,
                                                          bottomBarConfig: bottomBarConfig,
                                                          selecetedItem: selectedItem,
                                                          allItems: allItems,
                                                          albumUUID: albumUUID,
                                                          status: status)
        
        return (viewController, presenter)
    }
    
    class func initializeFaceImageAlbumViewController(with nibName: String, moduleOutput: PhotoVideoDetailModuleOutput? = nil, selectedItem: Item, allItems: [Item], albumUUID: String, albumItem: Item?, status: ItemStatus) -> PhotoVideoDetailModule {
        let elementsConfig = ElementTypes.detailsElementsConfig(for: selectedItem, status: status, viewType: .insideFIRAlbum)
        
        let bottomBarConfig = EditingBarConfig(elementsConfig: elementsConfig,
                                               style: .blackOpaque, tintColor: nil)
        
        let viewController = PhotoVideoDetailViewController(nibName: nibName, bundle: nil)
        let configurator = PhotoVideoDetailModuleConfigurator()
        let presenter = PhotoVideoDetailPresenter()
        configurator.configureModuleFromFaceImageAlbumForViewInput(viewInput: viewController,
                                                                   presenter: presenter,
                                                                   moduleOutput: moduleOutput,
                                                                   bottomBarConfig: bottomBarConfig,
                                                                   selecetedItem: selectedItem,
                                                                   allItems: allItems,
                                                                   albumUUID: albumUUID,
                                                                   albumItem: albumItem,
                                                                   status: status)
        return (viewController, presenter)
    }
}
