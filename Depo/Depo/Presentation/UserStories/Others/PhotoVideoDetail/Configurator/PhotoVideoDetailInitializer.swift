//
//  PhotoVideoDetailPhotoVideoDetailInitializer.swift
//  Depo
//
//  Created by Oleg on 01/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class PhotoVideoDetailModuleInitializer: NSObject {

    class func initializeViewController(with nibName: String, selectedItem: Item, allItems: [Item], status: ItemStatus) -> UIViewController {
        let photoVideoElementsConfig: [ElementTypes]
        var documentsElementsConfig: [ElementTypes] = [.share, .info, .move, .moveToTrash]
        
        if selectedItem.isLocalItem {
            photoVideoElementsConfig = [.share, .sync, .info]
        } else {
            switch status {
            case .hidden:
                photoVideoElementsConfig = [.unhide, .moveToTrash]
                documentsElementsConfig = [.unhide, .moveToTrash]
            case .trashed:
                photoVideoElementsConfig = [.restore, .delete]
                documentsElementsConfig = [.restore, .delete]
            default:
                if Device.isTurkishLocale {
                    photoVideoElementsConfig = [.share, .download, .print]
                } else {
                    photoVideoElementsConfig = [.share, .download]
                }
            }
        }
        
        let photoVideoBottomBarConfig = EditingBarConfig.init(elementsConfig: photoVideoElementsConfig,
                                                              style: .blackOpaque, tintColor: nil)
        
        let documentsBottomBarConfig = EditingBarConfig(elementsConfig: documentsElementsConfig,
                                                        style: .blackOpaque, tintColor: nil)
        
        let viewController = PhotoVideoDetailViewController(nibName: nibName, bundle: nil)
        let configurator = PhotoVideoDetailModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController,
                                                 photoVideoBottomBarConfig: photoVideoBottomBarConfig,
                                                 documentsBottomBarConfig: documentsBottomBarConfig,
                                                 selecetedItem: selectedItem,
                                                 allItems: allItems,
                                                 status: status)
        return viewController
    }
    
    class func initializeAlbumViewController(with nibName: String, selectedItem: Item, allItems: [Item], albumUUID: String, status: ItemStatus) -> UIViewController {
        let photoVideoElementsConfig: [ElementTypes]
        var documentsElementsConfig: [ElementTypes] = [.share, .info, .move, .removeFromAlbum]
        
        switch status {
        case .hidden:
            photoVideoElementsConfig = [.unhide, .moveToTrash]
            documentsElementsConfig = [.unhide, .moveToTrash]
        case .trashed:
            photoVideoElementsConfig = [.restore, .delete]
            documentsElementsConfig = [.restore, .delete]
        default:
            if Device.isTurkishLocale {
                photoVideoElementsConfig = [.share, .download, .edit, .print, .smash, .removeFromAlbum]
            } else {
                photoVideoElementsConfig = [.share, .download, .edit, .smash, .removeFromAlbum]
            }
        }
        
        let photoVideoBottomBarConfig = EditingBarConfig.init(elementsConfig: photoVideoElementsConfig,
                                                              style: .blackOpaque, tintColor: nil)
       
        let documentsBottomBarConfig = EditingBarConfig(elementsConfig: documentsElementsConfig,
                                                        style: .blackOpaque, tintColor: nil)
        
        let viewController = PhotoVideoDetailViewController(nibName: nibName, bundle: nil)
        let configurator = PhotoVideoDetailModuleConfigurator()
        configurator.configureModuleFromAlbumForViewInput(viewInput: viewController,
                                                          photoVideoBottomBarConfig: photoVideoBottomBarConfig,
                                                          documentsBottomBarConfig: documentsBottomBarConfig,
                                                          selecetedItem: selectedItem,
                                                          allItems: allItems,
                                                          albumUUID: albumUUID,
                                                          status: status)
        
        return viewController
    }
    
    class func initializeFaceImageAlbumViewController(with nibName: String, selectedItem: Item, allItems: [Item], albumUUID: String, albumItem: Item?, status: ItemStatus) -> UIViewController {
        
        let elementsConfig: [ElementTypes]
        if Device.isTurkishLocale {
            elementsConfig = [.share, .download, .print, .edit, .smash, .removeFromFaceImageAlbum]
        } else {
            elementsConfig = [.share, .download, .edit, .smash, .removeFromFaceImageAlbum]
        }
        
        let photoVideoBottomBarConfig = EditingBarConfig.init(elementsConfig: elementsConfig,
                                                              style: .blackOpaque, tintColor: nil)

        let documentsBottomBarConfig = EditingBarConfig(elementsConfig: [.share, .download, .info, .move, .removeFromFaceImageAlbum],
                                                        style: .blackOpaque, tintColor: nil)
        
        let viewController = PhotoVideoDetailViewController(nibName: nibName, bundle: nil)
        let configurator = PhotoVideoDetailModuleConfigurator()
        configurator.configureModuleFromFaceImageAlbumForViewInput(viewInput: viewController,
                                                          photoVideoBottomBarConfig: photoVideoBottomBarConfig,
                                                          documentsBottomBarConfig: documentsBottomBarConfig,
                                                          selecetedItem: selectedItem,
                                                          allItems: allItems,
                                                          albumUUID: albumUUID,
                                                          albumItem: albumItem,
                                                          status: status)
        
        return viewController
    }
    
//    class func initializeHiddenFaceImageAlbumViewController(with nibName: String, selectedItem: Item, allItems: [Item], albumUUID: String, albumItem: Item?, hideActions: Bool = false) -> UIViewController {
//        
//        let photoVideoBottomBarConfig = EditingBarConfig(elementsConfig: [.unhideAlbumItems, .moveToTrash],
//                                                         style: .blackOpaque, tintColor: nil)
//
//        let documentsBottomBarConfig = EditingBarConfig(elementsConfig: [.unhideAlbumItems, .moveToTrash],
//                                                        style: .blackOpaque, tintColor: nil)
//        
//        let viewController = PhotoVideoDetailViewController(nibName: nibName, bundle: nil)
//        let configurator = PhotoVideoDetailModuleConfigurator()
//        configurator.configureModuleFromHiddenFaceImageAlbumForViewInput(viewInput: viewController,
//                                                          photoVideoBottomBarConfig: photoVideoBottomBarConfig,
//                                                          documentsBottomBarConfig: documentsBottomBarConfig,
//                                                          selecetedItem: selectedItem,
//                                                          allItems: allItems,
//                                                          albumUUID: albumUUID,
//                                                          albumItem: albumItem,
//                                                          hideActions: hideActions)
//        
//        return viewController
//    }
//    
//    class func initializeHiddenAlbumViewController(with nibName: String, selectedItem: Item, allItems: [Item], albumUUID: String, albumItem: Item?, hideActions: Bool = false) -> UIViewController {
//        let photoVideoBottomBarConfig = EditingBarConfig(elementsConfig: [.unhideAlbumItems, .moveToTrash],
//                                                         style: .default, tintColor: nil)
//        
//        let documentsBottomBarConfig = EditingBarConfig(elementsConfig: [.unhideAlbumItems, .moveToTrash],
//                                                        style: .default, tintColor: nil)
//        
//        let viewController = PhotoVideoDetailViewController(nibName: nibName, bundle: nil)
//        let configurator = PhotoVideoDetailModuleConfigurator()
//        configurator.configureModuleFromHiddenAlbumForViewInput(viewInput: viewController,
//                                                                photoVideoBottomBarConfig: photoVideoBottomBarConfig,
//                                                                documentsBottomBarConfig: documentsBottomBarConfig,
//                                                                selecetedItem: selectedItem,
//                                                                allItems: allItems,
//                                                                albumUUID: albumUUID,
//                                                                albumItem: albumItem,
//                                                                hideActions: hideActions)
//        
//        return viewController
//    }
//    
//    class func initializeHiddenViewController(with nibName: String, selectedItem: Item, allItems: [Item], hideActions: Bool = false) -> UIViewController {
//        let photoVideoBottomBarConfig = EditingBarConfig(elementsConfig: [.unhide, .moveToTrash],
//                                                         style: .blackOpaque, tintColor: nil)
//        
//        let documentsBottomBarConfig = EditingBarConfig(elementsConfig: [.unhide, .moveToTrash],
//                                                        style: .blackOpaque, tintColor: nil)
//        
//        let viewController = PhotoVideoDetailViewController(nibName: nibName, bundle: nil)
//        let configurator = PhotoVideoDetailModuleConfigurator()
//        configurator.configureModuleForHiddenViewInput(viewInput: viewController,
//                                                       photoVideoBottomBarConfig: photoVideoBottomBarConfig,
//                                                       documentsBottomBarConfig: documentsBottomBarConfig,
//                                                       selecetedItem: selectedItem,
//                                                       allItems: allItems,
//                                                       hideActions: hideActions)
//        return viewController
//    }

}
