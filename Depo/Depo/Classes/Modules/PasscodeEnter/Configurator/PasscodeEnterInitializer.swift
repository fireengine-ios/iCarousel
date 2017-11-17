//
//  PasscodeEnterPasscodeEnterInitializer.swift
//  Depo
//
//  Created by Yaroslav Bondar on 02/10/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class PasscodeEnterModuleInitializer {
    
    weak var delegate: PasscodeEnterDelegate?
    let type: PasscodeInputViewType
    
    init(delegate: PasscodeEnterDelegate?, type: PasscodeInputViewType = .validate) {
        self.delegate = delegate
        self.type = type
    }
    
    var viewController: UIViewController {
        let nibName = String(describing: PasscodeEnterViewController.self)
        let viewController = PasscodeEnterViewController(nibName: nibName, bundle: nil)
        let configurator = PasscodeEnterModuleConfigurator(delegate: delegate, type: type)
        configurator.configureModuleForViewInput(viewInput: viewController)
        return viewController
    }
}
