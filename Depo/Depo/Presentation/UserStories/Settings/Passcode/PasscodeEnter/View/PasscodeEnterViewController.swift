//
//  PasscodeEnterPasscodeEnterViewController.swift
//  Depo
//
//  Created by Yaroslav Bondar on 02/10/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class PasscodeEnterViewController: ViewController {
    
    @IBOutlet weak var passcodeViewImp: PasscodeViewImp!
    let authtService = AuthenticationService()
    let accountService = AccountService()
    static func with(flow: PasscodeFlow, navigationTitle: String) -> PasscodeEnterViewController {
        let vc = PasscodeEnterViewController(nibName: "PasscodeEnterViewController", bundle: nil)
        vc.state = flow.startState
        vc.navigationTitle = navigationTitle
        return vc
    }
    
    var passcodeManager: PasscodeManager!
    
    var state: PasscodeState!
    var navigationTitle = ""
    var success: VoidHandler?
    var isTurkCellUser: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTitle(withString: navigationTitle)
        passcodeManager = PasscodeManagerImp(passcodeView: passcodeViewImp, state: state)
        passcodeManager.delegate = self
    }
}

// MARK: PasscodeEnterViewInput
extension PasscodeEnterViewController: PasscodeManagerDelegate {
    func passcodeLockDidFailNumberOfTries(_ lock: PasscodeManager) {
        authtService.logout { [weak self] in
            guard let `self` = self else {
                return
            }
            DispatchQueue.main.async {
                CoreDataStack.default.clearDataBase()
                let router = RouterVC()
                router.setNavigationController(controller: router.onboardingScreen)
                self.view.window?.endEditing(true)
                self.passcodeManager.storage.numberOfTries = self.passcodeManager.maximumInccorectPasscodeAttempts
            }
        }
    }
    
    func passcodeLockDidSucceed(_ lock: PasscodeManager) {
        lock.view.resignResponder()
        success?()
        if let unwrapedUserFlag = isTurkCellUser, unwrapedUserFlag {
            accountService.securitySettingsChange(turkcellPasswordAuthEnabled: false, mobileNetworkAuthEnabled: false,
                                                    success: nil, fail: nil)
        }
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
