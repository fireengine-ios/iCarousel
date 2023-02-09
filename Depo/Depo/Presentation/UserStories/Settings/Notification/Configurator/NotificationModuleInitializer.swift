//
//  NotificationModuleInitializer.swift
//  Depo
//
//  Created by yilmaz edis on 9.02.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

class NotificationModuleInitializer: NSObject {
    class func initializeViewController() -> NotificationViewController {
        let viewController = NotificationViewController()
        let configurator = NotificationConfigurator()
        configurator.configure(viewController: viewController)
        return viewController
    }
}
