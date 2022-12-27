//
//  DiscoverInitilizer.swift
//  Lifebox
//
//  Created by Ozan Salman on 17.11.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

import Foundation

class DiscoverInitilizer: NSObject {
    class func initializeViewController(with nibName: String) -> HeaderContainingViewController.ChildViewController {
        let viewController = DiscoverViewController(nibName: nibName, bundle: nil)
        let configurator = DiscoverConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController)
        viewController.floatingButtonsArray.append(contentsOf: [.takePhoto, .upload, .createAStory, .newFolder])
        return viewController 
    }
}
