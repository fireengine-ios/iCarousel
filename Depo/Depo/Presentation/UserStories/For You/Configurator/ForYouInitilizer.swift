//
//  ForYouInitilizer.swift
//  Depo
//
//  Created by Burak Donat on 22.07.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

class ForYouInitilizer: NSObject {
    class func initializeViewController(with nibName: String) -> HeaderContainingViewController.ChildViewController {
        let viewController = ForYouViewController(nibName: nibName, bundle: nil)
        let configurator = ForYouConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController)
        return viewController
    }
}
