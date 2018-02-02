//
//  FaceImagePhotosInitializer.swift
//  Depo_LifeTech
//
//  Created by Harbros Agency on 2/1/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class FaceImagePhotosInitializer {
    class func initializePeopleController(with nibName:String, albumUUID: String, item: Item) -> UIViewController {
        let viewController = FaceImagePhotosViewController(nibName: nibName, bundle: nil)
        
        let configurator = FaceImagePhotosConfigurator()
        
        configurator.configure(viewController: viewController, albumUUID: albumUUID, item: item)
        
        return viewController
    }
}
