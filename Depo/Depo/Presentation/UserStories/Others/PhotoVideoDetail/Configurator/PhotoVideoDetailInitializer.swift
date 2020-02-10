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

class PhotoVideoDetailModuleInitializer: NSObject {

    class func initializeViewController(with nibName: String, selectedItem: Item, allItems: [Item], status: ItemStatus) -> UIViewController {
        let elementsConfig = ElementTypes.detailsElementsConfig(for: selectedItem, status: status, viewType: .details)
        
        let bottomBarConfig = EditingBarConfig(elementsConfig: elementsConfig,
                                               style: .blackOpaque, tintColor: nil)
        
        let viewController = PhotoVideoDetailViewController(nibName: nibName, bundle: nil)
        let configurator = PhotoVideoDetailModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController,
                                                 bottomBarConfig: bottomBarConfig,
                                                 selecetedItem: selectedItem,
                                                 allItems: allItems,
                                                 status: status)
        return viewController
    }
    
    class func initializeAlbumViewController(with nibName: String, selectedItem: Item, allItems: [Item], albumUUID: String, status: ItemStatus) -> UIViewController {
        let elementsConfig = ElementTypes.detailsElementsConfig(for: selectedItem, status: status, viewType: .insideAlbum)
        
        let bottomBarConfig = EditingBarConfig(elementsConfig: elementsConfig,
                                               style: .blackOpaque, tintColor: nil)
        
        let viewController = PhotoVideoDetailViewController(nibName: nibName, bundle: nil)
        let configurator = PhotoVideoDetailModuleConfigurator()
        configurator.configureModuleFromAlbumForViewInput(viewInput: viewController,
                                                          bottomBarConfig: bottomBarConfig,
                                                          selecetedItem: selectedItem,
                                                          allItems: allItems,
                                                          albumUUID: albumUUID,
                                                          status: status)
        
        return viewController
    }
    
    class func initializeFaceImageAlbumViewController(with nibName: String, selectedItem: Item, allItems: [Item], albumUUID: String, albumItem: Item?, status: ItemStatus) -> UIViewController {
        let elementsConfig = ElementTypes.detailsElementsConfig(for: selectedItem, status: status, viewType: .insideFIRAlbum)
        
        let bottomBarConfig = EditingBarConfig(elementsConfig: elementsConfig,
                                               style: .blackOpaque, tintColor: nil)
        
        let viewController = PhotoVideoDetailViewController(nibName: nibName, bundle: nil)
        let configurator = PhotoVideoDetailModuleConfigurator()
        configurator.configureModuleFromFaceImageAlbumForViewInput(viewInput: viewController,
                                                          bottomBarConfig: bottomBarConfig,
                                                          selecetedItem: selectedItem,
                                                          allItems: allItems,
                                                          albumUUID: albumUUID,
                                                          albumItem: albumItem,
                                                          status: status)
        
        return viewController
    }
}
