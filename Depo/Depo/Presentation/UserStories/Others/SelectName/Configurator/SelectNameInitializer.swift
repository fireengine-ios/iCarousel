//
//  SelectNameSelectNameInitializer.swift
//  Depo
//
//  Created by Oleg on 15/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

struct CreateFolderSharedWithMeParameters {
    let projectId: String
    let rootFolderUuid: String?
}

class SelectNameModuleInitializer: NSObject {

    //Connect with object on storyboard
    @IBOutlet weak var selectnameViewController: SelectNameViewController!

    class func initializeViewController(with viewType: SelectNameScreenType, rootFolderID: String? = nil, isFavorites: Bool = false, moduleOutput: SelectNameModuleOutput? = nil) -> UIViewController {

        let viewController = SelectNameViewController.initFromNib()
        viewController.needToShowTabBar = true
        let configurator = SelectNameModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController,
                                                 viewType: viewType,
                                                 rootFolderID: rootFolderID,
                                                 isFavorites: isFavorites, 
                                                 moduleOutput: moduleOutput)

        return viewController
    }

    class func with(parameters: CreateFolderSharedWithMeParameters) -> UIViewController {
        let viewController = SelectNameViewController.initFromNib()
        viewController.needToShowTabBar = true
        let configurator = SelectNameModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController,
                                                 viewType: .selectFolderName,
                                                 parameters: parameters,
                                                 moduleOutput: nil)

        return viewController
    }
    
}
