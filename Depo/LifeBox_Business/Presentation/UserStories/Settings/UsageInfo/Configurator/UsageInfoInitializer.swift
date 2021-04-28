//
//  UsageInfoInitializer.swift
//  Depo
//
//  Created by Maksim Rahleev on 12.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class UsageInfoInitializer: NSObject {

    class func initializeViewController(with nibName: String) -> UIViewController {
        let viewController = UsageInfoViewController(nibName: nibName, bundle: nil)
        let configurator = UsageInfoConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController)
        return viewController
    }
}
