//
//  SyncContactsSyncContactsInitializer.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class SyncContactsModuleInitializer: NSObject {

    class func initializeViewController(with nibName: String) -> UIViewController {
        let viewController = SyncContactsViewController(nibName: nibName, bundle: nil)
        let configurator = SyncContactsModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController)
        viewController.floatingButtonsArray.append(contentsOf: [.takePhoto, .upload, .createAStory, .newFolder])
        return viewController
    }

}
