//
//  HomePageHomePageInitializer.swift
//  Depo
//
//  Created by AlexanderP on 22/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class HomePageModuleInitializer: NSObject {
    class func initializeViewController(with nibName: String) -> HeaderContainingViewController.ChildViewController {
        let viewController = HomePageViewController(nibName: nibName, bundle: nil)
        viewController.floatingButtonsArray.append(contentsOf: [.takePhoto, .upload, .createAStory])
        viewController.homePageDataSource.addNotPermittedCardViewTypes(types: [.prepareQuickScroll, .sharedWithMeUpload])
        let configurator = HomePageModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController)
        return viewController
    }
}
