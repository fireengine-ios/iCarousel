//
//  CreateCollageInitilizer.swift
//  Depo
//
//  Created by Ozan Salman on 2.03.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

class CreateCollageInitilizer: NSObject {
    
    class func initializeViewController() -> CreateCollageViewController {
        let viewController = CreateCollageViewController()
        let configurator = CreateCollageConfigurator()
        configurator.configure(viewController: viewController)
        return viewController
    }
}
