//
//  CreateStoryPreviewCreateStoryPreviewInitializer.swift
//  Depo
//
//  Created by Oleg on 18/10/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class CreateStoryPreviewModuleInitializer: NSObject {
    class func initializePreviewViewControllerForStory(with nibName: String, story: PhotoStory, response: CreateStoryResponse) -> UIViewController {
        let nibName = String(describing: CreateStoryPreviewViewController.self)
        let viewController = CreateStoryPreviewViewController(nibName: nibName, bundle: nil)
        let configurator = CreateStoryPreviewModuleConfigurator()
        configurator.configure(viewController: viewController, story: story, response: response)
        return viewController
    }
}
