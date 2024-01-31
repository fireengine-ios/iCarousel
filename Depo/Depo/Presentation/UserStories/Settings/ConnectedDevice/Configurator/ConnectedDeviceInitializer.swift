//
//  ConnectedDeviceInitializer.swift
//  Lifebox
//
//  Created by Ozan Salman on 27.12.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

class ConnectedDeviceInitializer: NSObject {
    class func initializeViewController() -> ConnectedDeviceViewController {
        let viewController = ConnectedDeviceViewController()
        let configurator = ConnectedDeviceConfigurator()
        configurator.configure(viewController: viewController)
        return viewController
    }
}
