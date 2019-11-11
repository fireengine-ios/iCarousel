//
//  HomePageHomePageInitializer.swift
//  Depo
//
//  Created by AlexanderP on 22/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class HomePageModuleInitializer: NSObject {

    //Connect with object on storyboard
    @IBOutlet weak var homepageViewController: HomePageViewController!

    override func awakeFromNib() {

        let configurator = HomePageModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: homepageViewController)
    }
    
    func conf() {
        let configurator = HomePageModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: homepageViewController)
    }

    class func initializeViewController(with nibName: String) -> UIViewController {
        let viewController = HomePageViewController(nibName: nibName, bundle: nil)
        viewController.floatingButtonsArray.append(contentsOf: [.takePhoto, .upload, .createAStory, .newFolder])
        viewController.homePageDataSource.addNotPermittedCardViewTypes(types: [.prepareQuickScroll])
        let configurator = HomePageModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController)
        return viewController
    }
    
}
