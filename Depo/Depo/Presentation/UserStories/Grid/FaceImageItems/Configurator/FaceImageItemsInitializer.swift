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
    
        let configurator = FaceImageItemsConfigurator()
        
        configurator.configure(viewController: viewController, remoteServices: PeopleItemsService(requestSize: 20), title: TextConstants.myStreamPeopleTitle)
        
        return viewController
    }
    
    class func initializeThingsController(with nibName:String) -> UIViewController {
        let viewController = FaceImageItemsViewController(nibName: nibName, bundle: nil)
        
        let configurator = FaceImageItemsConfigurator()
        
        configurator.configure(viewController: viewController, remoteServices: ThingsItemsService(requestSize: 20), title: TextConstants.myStreamThingsTitle)
        
        return viewController
    }
    
    class func initializePlacesController(with nibName:String) -> UIViewController {
        let viewController = FaceImageItemsViewController(nibName: nibName, bundle: nil)
        
        let configurator = FaceImageItemsConfigurator()
        
        configurator.configure(viewController: viewController, remoteServices: PlacesItemsService(requestSize: 20), title: TextConstants.myStreamPlacesTitle)
        
        return viewController
    }
}

