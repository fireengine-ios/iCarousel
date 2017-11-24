//
//  UploadedItemsUploadedItemsInitializer.swift
//  Depo
//
//  Created by Oleg on 27/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class UploadedItemsModuleInitializer: NSObject {

    //Connect with object on storyboard
    @IBOutlet weak var uploadeditemsViewController: UploadedItemsViewController!

    class func initializeViewController(with nibName:String) -> UIViewController {
        let viewController = UploadedItemsViewController(nibName: nibName, bundle: nil)
        let configurator = UploadedItemsModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController)
        return viewController
    }

}
