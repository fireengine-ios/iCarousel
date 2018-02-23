//
//  FaceImageItemsInitializer.swift
//  Depo
//
//  Created by Harbros on 29.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class FaceImageItemsInitializer: NSObject {

    class func initializePeopleController(with nibName:String, moduleOutput: LBAlbumLikePreviewSliderModuleInput?) -> UIViewController {
        let viewController = FaceImageItemsViewController(nibName: nibName, bundle: nil)
        viewController.isCanChangeVisibility = true
    
        let configurator = FaceImageItemsConfigurator()
        
        configurator.configure(viewController: viewController, remoteServices: PeopleItemsService(requestSize: 100), title: TextConstants.myStreamPeopleTitle, moduleOutput:  moduleOutput)
        
        return viewController
    }
    
    class func initializeThingsController(with nibName:String) -> UIViewController {
        let viewController = FaceImageItemsViewController(nibName: nibName, bundle: nil)
        
        let configurator = FaceImageItemsConfigurator()
        
        configurator.configure(viewController: viewController, remoteServices: ThingsItemsService(requestSize: 100), title: TextConstants.myStreamThingsTitle)
        
        return viewController
    }
    
    class func initializePlacesController(with nibName:String) -> UIViewController {
        let viewController = FaceImageItemsViewController(nibName: nibName, bundle: nil)
        
        let configurator = FaceImageItemsConfigurator()
        
        configurator.configure(viewController: viewController, remoteServices: PlacesItemsService(requestSize: 100), title: TextConstants.myStreamPlacesTitle)
        
        return viewController
    }
}

