//
//  DarkModeConfigurator.swift
//  Depo
//
//  Created by Burak Donat on 6.12.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation

class DarkModeConfigurator {

    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController) {
        if let viewController = viewInput as? DarkModeViewController {
            configure(viewController: viewController)
        }
    }

    private func configure(viewController: DarkModeViewController) {

    }
}
