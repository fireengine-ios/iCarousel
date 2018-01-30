//
//  PhotoVideoDetailPhotoVideoDetailInitializer.swift
//  Depo
//
//  Created by Oleg on 01/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class PhotoVideoDetailModuleInitializer: NSObject {

    //Connect with object on storyboard
    var photovideodetailViewController: PhotoVideoDetailViewController!

    class func initializeViewController(with nibName:String, selectedItem: Item, allItems: [Item], hideActions: Bool = false) -> UIViewController {
        let photoVideoBottomBarConfig = EditingBarConfig(elementsConfig: [.share, .print, .edit],
                                                         style: .blackOpaque, tintColor: nil)
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
    
    class func initializeAlbumViewController(with nibName:String, selectedItem: Item, allItems: [Item], albumUUID: String, hideActions: Bool = false) -> UIViewController {
        let photoVideoBottomBarConfig = EditingBarConfig(elementsConfig: [.share, .print, .edit, .removeFromAlbum],
                                                         style: .blackOpaque, tintColor: nil)
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

}
