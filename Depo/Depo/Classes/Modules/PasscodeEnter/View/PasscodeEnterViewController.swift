//
//  PasscodeEnterPasscodeEnterViewController.swift
//  Depo
//
//  Created by Yaroslav Bondar on 02/10/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class PasscodeEnterViewController: UIViewController {
    
    @IBOutlet weak var passcodeViewImp: PasscodeViewImp!
    
    static func with(flow: PasscodeFlow) -> PasscodeEnterViewController {
        let vc = PasscodeEnterViewController(nibName: "PasscodeEnterViewController", bundle: nil)
        vc.state = flow.startState
        return vc
    }
    
    var passcodeManager: PasscodeManager!
    private lazy var biometricsManager: BiometricsManager = factory.resolve()
    
    var state: PasscodeState!
    var success: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTitle(withString: TextConstants.passcodeEnterTitle)
        passcodeManager = PasscodeManagerImp(passcodeView: passcodeViewImp, state: state)
        passcodeManager.delegate = self
    }
}

// MARK: PasscodeEnterViewInput
extension PasscodeEnterViewController: PasscodeManagerDelegate {
    func passcodeLockDidFailNumberOfTries(_ lock: PasscodeManager) {
        AuthenticationService().logout {
            DispatchQueue.main.async {
                CoreDataStack.default.clearDataBase()
                let router = RouterVC()
                router.setNavigationController(controller: router.onboardingScreen)
                self.view.window?.endEditing(true)
                self.passcodeManager.storage.clearPasscode()
                self.passcodeManager.storage.numberOfTries = self.passcodeManager.maximumInccorectPasscodeAttempts
                self.biometricsManager.isEnabled = false
            }
        }
    }
    
    func passcodeLockDidSucceed(_ lock: PasscodeManager) {
        lock.view.resignResponder()
        success?()
    }
    
    func passcodeLockDidFail(_ lock: PasscodeManager) {
        lock.view.passcodeInput.animateError()
        if lock.storage.numberOfTries != lock.maximumInccorectPasscodeAttempts {
            lock.view.passcodeOutput.animateError(with: lock.storage.numberOfTries)
        } else {
            lock.view.passcodeOutput.animateError(with: TextConstants.passcodeDontMatch)
        }
    }
}
