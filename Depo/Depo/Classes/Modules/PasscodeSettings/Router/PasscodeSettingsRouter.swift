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
    
    func passcode(delegate: PasscodeEnterDelegate?, type: PasscodeInputViewType) {
        let vc = router.passcode(delegate: delegate, type: type)
        router.pushViewController(viewController: vc)
    }
    
    func closePasscode() {
        router.popViewController()
    }
}
