//
//  FaceImageItemsInitializer.swift
//  Depo
//
//  Created by Harbros on 29.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

class FaceImageItemsInitializer: NSObject {

    class func initializePeopleController(with nibName:String) -> UIViewController {
        let viewController = FaceImageItemsViewController(nibName: nibName, bundle: nil)
        viewController.isCanChangeVisibility = true
    
        let configurator = FaceImageItemsConfigurator()
        
        configurator.configure(viewController: viewController, remoteServices: PeopleItemsService(requestSize: 100), title: TextConstants.myStreamPeopleTitle)
        
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

