//
//  PasscodeController.swift
//  LifeBox-new
//
//  Created by Bondar Yaroslav on 14/11/2017.
//  Copyright © 2017 Bondar Yaroslav. All rights reserved.
//

import UIKit

class PasscodeController: UIViewController {
    
    static func with(state: PasscodeState) -> PasscodeController {
        let sb = UIStoryboard(name: "Settings", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "PasscodeController") as! PasscodeController
        vc.state = state
        return vc
    }
    
    @IBOutlet weak var passcodeView: PasscodeViewImp!
    
    private var passcodeManager: PasscodeManager!
    
    var state: PasscodeState!
    var success: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        PasscodeStorageDefaults().passcode = "2222"
        //let state = ValidatePasscodeState()
//        let state = OldPasscodeState()
        passcodeManager = PasscodeManagerImp(passcodeView: passcodeView, state: state)
        passcodeManager.delegate = self
    }
}
extension PasscodeController: PasscodeManagerDelegate {
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
