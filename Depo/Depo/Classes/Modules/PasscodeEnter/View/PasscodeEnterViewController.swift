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
    
    @IBOutlet weak var passcodeView: PasscodeView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passcodeView.delegate = output
        output.viewIsReady()
    }
}

// MARK: PasscodeEnterViewInput
extension PasscodeEnterViewController: PasscodeEnterViewInput {
    func setPasscode(type: PasscodeInputViewType) {
        passcodeView.set(type: type)
    }
}
