//
//  FileInfoFileInfoInitializer.swift
//  Depo
//
//  Created by Oleg on 18/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class FileInfoModuleInitializer: NSObject {

    //Connect with object on storyboard
    @IBOutlet weak var fileinfoViewController: FileInfoViewController!

    class func initializeViewController(with nibName: String, item: BaseDataSourceItem, moduleOutput: FileInfoModuleOutput? = nil) -> UIViewController {
        let viewController = FileInfoViewController(nibName: nibName, bundle: nil)
        let configurator = FileInfoModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController, item: item, moduleOutput: moduleOutput)
        return viewController
    }

}
