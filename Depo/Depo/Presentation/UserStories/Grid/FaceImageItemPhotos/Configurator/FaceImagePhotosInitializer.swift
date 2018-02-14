//
//  FaceImagePhotosInitializer.swift
//  Depo_LifeTech
//
//  Created by Harbros Agency on 2/1/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class FaceImagePhotosInitializer {
    class func initializeController(with nibName:String, albumUUID: String, item: Item, coverPhotoURL: URL, moduleOutput: FaceImageItemsModuleOutput?) -> UIViewController {
        let viewController = FaceImagePhotosViewController(nibName: nibName, bundle: nil)
        
        let configurator = FaceImagePhotosConfigurator()
        configurator.configure(viewController: viewController, albumUUID: albumUUID, item: item, coverPhotoURL: coverPhotoURL, moduleOutput: moduleOutput)
        
        return viewController
    }
}
