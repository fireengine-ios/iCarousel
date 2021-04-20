//
//  TermsOfUseInitializer.swift
//  Depo
//
//  Created by Konstantin on 8/14/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class TermsOfUseInitializer {
    static var viewController: TermsOfUseViewController {
        let nibName = String(describing: TermsOfUseViewController.self)
        let viewController = TermsOfUseViewController(nibName: nibName, bundle: nil)
        let configurator = TermsOfUseModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController)
        return viewController
    }
}
