//
//  SelectNameSelectNameInitializer.swift
//  Depo
//
//  Created by Oleg on 15/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

struct CreateFolderParameters {
    let accountUuid: String
    let rootFolderUuid: String?
    let isShared: Bool
}

class SelectNameModuleInitializer: NSObject {

    //Connect with object on storyboard
    @IBOutlet weak var selectnameViewController: SelectNameViewController!

    class func with(parameters: CreateFolderParameters) -> UIViewController {
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
