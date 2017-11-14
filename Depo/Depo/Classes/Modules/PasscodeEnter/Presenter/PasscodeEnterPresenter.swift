//
//  PasscodeEnterPasscodeEnterPresenter.swift
//  Depo
//
//  Created by Yaroslav Bondar on 02/10/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol PasscodeEnterDelegate: class {
    func finishPasscode(with type: PasscodeInputViewType)
}

class PasscodeEnterPresenter {
    weak var view: PasscodeEnterViewInput?
    var interactor: PasscodeEnterInteractorInput!
    var router: PasscodeEnterRouterInput!
    
    weak var delegate: PasscodeEnterDelegate?
    var type = PasscodeInputViewType.validate
}

// MARK: PasscodeEnterViewOutput
extension PasscodeEnterPresenter: PasscodeEnterViewOutput {
    func viewIsReady() {
        view?.setPasscode(type: type)
    }
}

// MARK: PasscodeEnterInteractorOutput
extension PasscodeEnterPresenter: PasscodeEnterInteractorOutput {

}

// MARK: PasscodeEnterModuleInput
extension PasscodeEnterPresenter: PasscodeEnterModuleInput {

}

// MARK: - PasscodeViewDelegate
extension PasscodeEnterPresenter: PasscodeViewDelegate {
    func finishSetNew(passcode: Passcode) {
        interactor.save(passcode: passcode)
        delegate?.finishPasscode(with: type)
    }
    func finishValidate() {
        delegate?.finishPasscode(with: type)
//        let v = view as! PasscodeEnterViewController
//        v.passcodeView.resignFirstResponder()
    }
    func check(passcode: Passcode) -> Bool {
        return interactor.isEqual(to: passcode)
    }
}
