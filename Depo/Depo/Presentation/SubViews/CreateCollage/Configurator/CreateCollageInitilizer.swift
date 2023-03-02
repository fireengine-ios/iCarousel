//
//  CreateCollageInitilizer.swift
//  Depo
//
//  Created by Ozan Salman on 2.03.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

class CreateCollageInitilizer: NSObject {
//    class func initializeViewController(with nibName: String) -> HeaderContainingViewController.ChildViewController {
//        let viewController = CreateCollageViewController(nibName: nibName, bundle: nil)
//        let configurator = CreateCollageConfigurator()
//        configurator.configureModuleForViewInput(viewInput: viewController)
//        viewController.floatingButtonsArray.append(contentsOf: [.takePhoto, .upload, .createAStory, .createAlbum, .photopick])
//        return viewController
//    }
    class func initializeViewController() -> CreateCollageViewController {
        let viewController = CreateCollageViewController()
        let configurator = CreateCollageConfigurator()
        configurator.configure(viewController: viewController)
        return viewController
    }
}
