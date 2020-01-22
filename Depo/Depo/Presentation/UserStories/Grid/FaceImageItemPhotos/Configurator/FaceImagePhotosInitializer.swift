//
//  FaceImagePhotosInitializer.swift
//  Depo_LifeTech
//
//  Created by Harbros Agency on 2/1/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class FaceImagePhotosInitializer {
    class func initializeController(with nibName: String, album: AlbumItem, item: Item, status: ItemStatus, moduleOutput: FaceImageItemsModuleOutput?, isSearchItem: Bool) -> UIViewController {
        let viewController = FaceImagePhotosViewController(nibName: nibName, bundle: nil)
        viewController.parentUUID = album.uuid
        
        let configurator = FaceImagePhotosConfigurator()
        configurator.configure(viewController: viewController, album: album, item: item, status: status, moduleOutput: moduleOutput, isSearchItem: isSearchItem)
        
        return viewController
    }
}
