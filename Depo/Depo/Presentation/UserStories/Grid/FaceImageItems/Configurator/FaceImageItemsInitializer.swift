//
//  FaceImageItemsInitializer.swift
//  Depo
//
//  Created by Harbros on 29.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class FaceImageItemsInitializer: NSObject {

    class func initializePeopleController(with nibName: String, moduleOutput: LBAlbumLikePreviewSliderModuleInput?) -> UIViewController {
        let viewController = FaceImageItemsViewController(nibName: nibName, bundle: nil)
        viewController.isCanChangeVisibility = true
        viewController.forYouControllerSection = .people
        let configurator = FaceImageItemsConfigurator()
        
        configurator.configure(viewController: viewController, remoteServices: PeopleItemsService(requestSize: RequestSizeConstant.faceImageItemsRequestSize), title: TextConstants.myStreamPeopleTitle, moduleOutput: moduleOutput)
        
        return viewController
    }
    
    class func initializeThingsController(with nibName: String, moduleOutput: LBAlbumLikePreviewSliderModuleInput?) -> UIViewController {
        let viewController = FaceImageItemsViewController(nibName: nibName, bundle: nil)
        viewController.forYouControllerSection = .things
        let configurator = FaceImageItemsConfigurator()
        
        configurator.configure(viewController: viewController, remoteServices: ThingsItemsService(requestSize: RequestSizeConstant.faceImageItemsRequestSize), title: TextConstants.myStreamThingsTitle, moduleOutput: moduleOutput)
        
        return viewController
    }
    
    class func initializePlacesController(with nibName: String, moduleOutput: LBAlbumLikePreviewSliderModuleInput?) -> UIViewController {
        let viewController = FaceImageItemsViewController(nibName: nibName, bundle: nil)
        viewController.forYouControllerSection = .places
        let configurator = FaceImageItemsConfigurator()
        
        configurator.configure(viewController: viewController, remoteServices: PlacesItemsService(requestSize: RequestSizeConstant.faceImageItemsRequestSize), title: TextConstants.myStreamPlacesTitle, moduleOutput: moduleOutput)
        
        return viewController
    }
}
