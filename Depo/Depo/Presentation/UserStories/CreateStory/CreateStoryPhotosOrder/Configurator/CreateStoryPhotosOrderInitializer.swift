//
//  CreateStoryPhotosOrderCreateStoryPhotosOrderInitializer.swift
//  Depo
//
//  Created by Oleg on 03/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class CreateStoryPhotosOrderModuleInitializer: NSObject {

    //Connect with object on storyboard
    @IBOutlet weak var createstoryphotosorderViewController: CreateStoryPhotosOrderViewController!

    class func initializeViewController(with nibName: String, story: PhotoStory) -> UIViewController {
        let viewController = CreateStoryPhotosOrderViewController(nibName: nibName, bundle: nil)
        let configurator = CreateStoryPhotosOrderModuleConfigurator()
        configurator.configure(viewController: viewController, story: story)
        return viewController
    }

}
