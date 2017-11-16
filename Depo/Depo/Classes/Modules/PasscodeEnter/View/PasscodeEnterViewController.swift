//
//  PasscodeEnterPasscodeEnterViewController.swift
//  Depo
//
//  Created by Yaroslav Bondar on 02/10/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class PasscodeEnterViewController: UIViewController {
    var output: PasscodeEnterViewOutput!
    
    @IBOutlet weak var passcodeViewImp: PasscodeViewImp!
    
    static func with(flow: PasscodeFlow) -> PasscodeEnterViewController {
        let vc = PasscodeEnterViewController(nibName: "PasscodeEnterViewController", bundle: nil)
        vc.state = flow.startState
        return vc
    }
    
    private var passcodeManager: PasscodeManager!
    
    var state: PasscodeState!
    var success: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passcodeManager = PasscodeManagerImp(passcodeView: passcodeViewImp, state: state)
        passcodeManager.delegate = self
    }
}

// MARK: PasscodeEnterViewInput
extension PasscodeEnterViewController: PasscodeManagerDelegate {
    func passcodeLockDidFailNumberOfTries(_ lock: PasscodeManager) {
        print("logout")
    }
    
    func passcodeLockDidSucceed(_ lock: PasscodeManager) {
        success?()
    }
    
    func passcodeLockDidFail(_ lock: PasscodeManager) {
        print("- numberOfTries", lock.storage.numberOfTries)
        lock.view.passcodeInput.animateError()
        if lock.storage.numberOfTries != lock.maximumInccorectPasscodeAttempts {
            lock.view.passcodeOutput.animateError(with: lock.storage.numberOfTries)
        } else {
            lock.view.passcodeOutput.animateError(with: "Passcodes don't match, please try again")
        }
    }
}

