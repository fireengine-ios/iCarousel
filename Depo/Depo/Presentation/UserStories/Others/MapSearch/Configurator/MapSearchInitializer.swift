//
//  MapSearchInitializer.swift
//  Depo
//
//  Created by Hady on 2/15/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

final class MapSearchInitializer: NSObject {
    class func initialize() -> MapSearchViewController {
        let viewController = MapSearchViewController()
        let configurator = MapSearchConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController)
        return viewController
    }
}
