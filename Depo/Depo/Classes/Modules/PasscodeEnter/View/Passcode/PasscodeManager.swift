//
//  PasscodeFlowManager.swift
//  LifeBox-new
//
//  Created by Bondar Yaroslav on 14/11/2017.
//  Copyright © 2017 Bondar Yaroslav. All rights reserved.
//

import UIKit


protocol PasscodeManager: class {
    var view: PasscodeView { get }
    var storage: PasscodeStorage { get }
    func changeState(to state: PasscodeState)
    weak var delegate: PasscodeManagerDelegate? { get set }
    var isTouchIDAllowed: Bool { get }
    func authenticateWithBiometrics()
    var maximumInccorectPasscodeAttempts: Int { get }
}

protocol PasscodeManagerDelegate: class {
    func passcodeLockDidSucceed(_ lock: PasscodeManager)
    func passcodeLockDidFail(_ lock: PasscodeManager)
    func passcodeLockDidFailNumberOfTries(_ lock: PasscodeManager)
}

final class PasscodeManagerImp {
    let view: PasscodeView
    let storage: PasscodeStorage
    
    //    var passcode = ""
    
    var state: PasscodeState
    lazy var touchIdManager = TouchIdManager()
    
    weak var delegate: PasscodeManagerDelegate?
    
    init(passcodeView: PasscodeView, state: PasscodeState, passcodeStorage: PasscodeStorage = PasscodeStorageDefaults()) {
        self.view = passcodeView
        self.storage = passcodeStorage
        self.state = state
        passcodeView.passcodeInput.delegate = self
        changeState(to: state)
    }
}
extension PasscodeManagerImp: PasscodeManager {
    var maximumInccorectPasscodeAttempts: Int {
        return 5
    }
    
    func changeState(to state: PasscodeState) {
        self.state = state
        view.update(for: state)
        view.passcodeInput.clearPasscode()
        //storage.clearPasscode()
        
        if state.isBiometricsAllowed {
            authenticateWithBiometrics()
        }
    }
    
    var isTouchIDAllowed: Bool {
        return true
    }
    
    func authenticateWithBiometrics() {
        touchIdManager.authenticate(reason: state.title) { success in
            DispatchQueue.main.async {
                if success {
                    let passcode = self.storage.passcode
                    self.view.passcodeInput.passcode = passcode
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.state.finish(with: passcode, manager: self)
                    }
                }
            }
        }
    }
}

extension PasscodeManagerImp: PasscodeInputViewDelegate {
    func finish(with passcode: Passcode) {
        state.finish(with: passcode, manager: self)
        //        storage.save(passcode: passcode)
    }
    func finishErrorAnimation() {
        view.passcodeInput.clearPasscode()
    }
}
