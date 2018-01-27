//
//  CreateStoryNameCreateStoryNameInitializer.swift
//  Depo
//
//  Created by Oleg on 01/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class CreateStoryNameModuleInitializer: NSObject {

    //Connect with object on storyboard
    @IBOutlet weak var createstorynameViewController: CreateStoryNameViewController!

    class func initializeViewController(with nibName:String, needSelectionItems: Bool) -> CreateStoryNameViewController {
        let viewController = CreateStoryNameViewController(nibName: nibName, bundle: nil)
        viewController.needShowTabBar = true
        let configurator = CreateStoryNameModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController, needSelectionItems: needSelectionItems)
        return viewController
    }

}
