//
//  PasscodeSettingsPasscodeSettingsRouter.swift
//  Depo
//
//  Created by Yaroslav Bondar on 03/10/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class PasscodeSettingsRouter {
    let router = RouterVC()
}

// MARK: PasscodeSettingsRouterInput
extension PasscodeSettingsRouter: PasscodeSettingsRouterInput {
    
    func closePasscode() {
        router.popViewController()
    }
    
    func changePasscode() {
        let vc = PasscodeEnterViewController.with(flow: .setNew)
        let routerVC = RouterVC()
        vc.success = {
            routerVC.navigationController?.popViewController(animated: true)
        }
        routerVC.pushViewController(viewController: vc)
    }
    
    func setPasscode() {
        let vc = PasscodeEnterViewController.with(flow: .create)
        let routerVC = RouterVC()
        vc.success = {
            routerVC.navigationController?.popViewController(animated: true)
        }
        routerVC.pushViewController(viewController: vc)
    }
}
