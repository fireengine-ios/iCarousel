//
//  PhotoVideoDetailPhotoVideoDetailInitializer.swift
//  Depo
//
//  Created by Oleg on 01/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class PhotoVideoDetailModuleInitializer: NSObject {

    class func initializeViewController(with nibName: String, selectedItem: Item, allItems: [Item], hideActions: Bool = false) -> UIViewController {
        var photoVideoBottomBarConfig = EditingBarConfig.init(elementsConfig: [], style: .blackOpaque, tintColor: nil)
        
        if !selectedItem.isLocalItem {
            photoVideoBottomBarConfig = EditingBarConfig(elementsConfig: [.share, .download, .print,],
                                                         style: .blackOpaque, tintColor: nil)
            
            let langCode = Device.locale
            if langCode != "tr" {
                photoVideoBottomBarConfig = EditingBarConfig(elementsConfig: [.share, .download],
                                                             style: .blackOpaque, tintColor: nil)
            }
//            if selectedItem.fileType == .image, selectedItem.name?.split(separator: ".").last != "gif" {
//                photoVideoBottomBarConfig.elementsConfig.append( .smash)
//            }
        } else {
            photoVideoBottomBarConfig = EditingBarConfig(elementsConfig: [.share, .sync, .info],
                                                         style: .blackOpaque, tintColor: nil)
        }
        
        let documentsBottomBarConfig = EditingBarConfig(elementsConfig: [.share, .info, .move, .delete],
                                                        style: .blackOpaque, tintColor: nil)
        let viewController = PhotoVideoDetailViewController(nibName: nibName, bundle: nil)
        let configurator = PhotoVideoDetailModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController,
                                                 photoVideoBottomBarConfig: photoVideoBottomBarConfig,
                                                 documentsBottomBarConfig: documentsBottomBarConfig,
                                                 selecetedItem: selectedItem,
                                                 allItems: allItems,
                                                 hideActions: hideActions)
        return viewController
    }
    
    class func initializeAlbumViewController(with nibName: String, selectedItem: Item, allItems: [Item], albumUUID: String, hideActions: Bool = false) -> UIViewController {
        var photoVideoBottomBarConfig = EditingBarConfig(elementsConfig: [.share, .download, .edit, .print, .removeFromAlbum],
                                                         style: .blackOpaque, tintColor: nil)
        
        let langCode = Device.locale
        if langCode != "tr" {
            photoVideoBottomBarConfig = EditingBarConfig(elementsConfig: [.share, .download, .edit, .removeFromAlbum],
                                                         style: .blackOpaque, tintColor: nil)
        }
        
        let documentsBottomBarConfig = EditingBarConfig(elementsConfig: [.share, .info, .move, .removeFromAlbum],
                                                        style: .blackOpaque, tintColor: nil)
        
        let viewController = PhotoVideoDetailViewController(nibName: nibName, bundle: nil)
        let configurator = PhotoVideoDetailModuleConfigurator()
        configurator.configureModuleFromAlbumForViewInput(viewInput: viewController,
                                                          photoVideoBottomBarConfig: photoVideoBottomBarConfig,
                                                          documentsBottomBarConfig: documentsBottomBarConfig,
                                                          selecetedItem: selectedItem,
                                                          allItems: allItems,
                                                          albumUUID: albumUUID,
                                                          hideActions: hideActions)
        
        return viewController
    }
    
    class func initializeFaceImageAlbumViewController(with nibName: String, selectedItem: Item, allItems: [Item], albumUUID: String, albumItem: Item?, hideActions: Bool = false) -> UIViewController {
        var photoVideoBottomBarConfig = EditingBarConfig(elementsConfig: [.share, .download, .print, .edit, .removeFromFaceImageAlbum],
                                                         style: .blackOpaque, tintColor: nil)
        
        let langCode = Device.locale
        if langCode != "tr" {
            photoVideoBottomBarConfig = EditingBarConfig(elementsConfig: [.share, .download, .edit, .removeFromFaceImageAlbum],
                                                             style: .blackOpaque, tintColor: nil)
        }

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
                                                          hideActions: hideActions)
        
        return viewController
    }

}
