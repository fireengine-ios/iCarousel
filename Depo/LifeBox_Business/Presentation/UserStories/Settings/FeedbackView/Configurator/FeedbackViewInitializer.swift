//
//  FeedbackViewFeedbackViewInitializer.swift
//  Depo
//
//  Created by Oleg on 01/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class FeedbackViewModuleInitializer: NSObject {

    class func initializeViewController(with nibName: String) -> FeedbackViewController {
        let viewController = FeedbackViewController(nibName: nibName, bundle: nil)
        let configurator = FeedbackViewModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController)
        return viewController
    }

}
