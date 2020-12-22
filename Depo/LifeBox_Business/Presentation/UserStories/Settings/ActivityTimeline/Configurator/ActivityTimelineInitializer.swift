//
//  ActivityTimelineActivityTimelineInitializer.swift
//  Depo
//
//  Created by Yaroslav Bondar on 13/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class ActivityTimelineModuleInitializer: NSObject {

    static func initialize<T: UIViewController>(_ vc: T.Type) -> UIViewController {
        let viewController = ActivityTimelineViewController(nibName: String(describing: vc), bundle: nil)
        let configurator = ActivityTimelineModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController)
        return viewController
    }
}
