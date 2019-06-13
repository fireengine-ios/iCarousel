//
//  SelectNameSelectNameInitializer.swift
//  Depo
//
//  Created by Oleg on 15/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class SelectNameModuleInitializer: NSObject {

    //Connect with object on storyboard
    @IBOutlet weak var selectnameViewController: SelectNameViewController!

    class func initializeViewController(with nibName: String, viewType: SelectNameScreenType, rootFolderID: String? = nil, isFavorites: Bool = false) -> UIViewController {
        let viewController = SelectNameViewController(nibName: nibName, bundle: nil)
        viewController.needToShowTabBar = true
        let configurator = SelectNameModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController,
                                                 viewType: viewType,
                                                 rootFolderID: rootFolderID,
                                                 isFavorites: isFavorites)
        return viewController
    }

    
}
