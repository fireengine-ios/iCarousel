//
//  FaceImagePhotosInitializer.swift
//  Depo_LifeTech
//
//  Created by Harbros Agency on 2/1/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class FaceImagePhotosInitializer {
    class func initializeController(with nibName:String, albumUUID: String, coverPhotoURL: URL, item: Item) -> UIViewController {
        let viewController = FaceImagePhotosViewController(nibName: nibName, bundle: nil)
        viewController.loadView()
        
        let configurator = FaceImagePhotosConfigurator()
        configurator.configure(viewController: viewController, albumUUID: albumUUID, coverPhotoURL: coverPhotoURL, item: item)
        
        return viewController
    }
}
