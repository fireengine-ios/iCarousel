//
//  PublicShareInitializer.swift
//  Depo
//
//  Created by Burak Donat on 8.01.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

class PublicShareInitializer: NSObject {
    class func initializeSaveToMyLifeboxViewController(with publicToken: String) -> PublicShareViewController {
        let viewController = PublicShareViewController(nibName: "PublicShareViewController", bundle: nil)
        let configurator = PublicShareConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController, publicToken: publicToken)
        return viewController
    }
    
    class func initializeSaveToMyLifeboxViewController(with item: WrapData) -> PublicShareViewController {
        let viewController = PublicShareViewController(nibName: "PublicShareViewController", bundle: nil)
        let configurator = PublicShareConfigurator()
        configurator.configureModuleForInnerFolder(viewInput: viewController, item: item)
        return viewController
    }
}
