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
    
    func changePasscode(isTurkCellUser: Bool) {
        let vc = PasscodeEnterViewController.with(flow: .setNew, navigationTitle: TextConstants.passcodeSetTitle)
        vc.isTurkCellUser = isTurkCellUser
        vc.success = {
            self.router.navigationController?.popViewController(animated: true)
        }
        
        router.pushViewController(viewController: vc)
    }
    
    func setPasscode(isTurkCellUser: Bool, finishCallBack: (() -> Void)?) {
        let vc = PasscodeEnterViewController.with(flow: .create, navigationTitle: TextConstants.passcodeSetTitle)
        vc.isTurkCellUser = isTurkCellUser
        vc.success = {
            finishCallBack?()
            self.router.navigationController?.popViewController(animated: true)
        }
        
        router.pushViewController(viewController: vc)
    }
}
