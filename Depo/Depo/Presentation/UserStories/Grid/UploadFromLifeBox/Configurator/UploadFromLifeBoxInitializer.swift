//
//  UploadFromLifeBoxUploadFromLifeBoxInitializer.swift
//  Depo
//
//  Created by Oleg on 01/12/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class UploadFromLifeBoxModuleInitializer: NSObject {
    static var viewController: UIViewController {
        let nibName = String(describing: UploadFromLifeBoxViewController.self)
        let viewController = UploadFromLifeBoxViewController(nibName: nibName, bundle: nil)
        let configurator = UploadFromLifeBoxModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController)
        return viewController
    }
}
