//
//  PasscodeSettingsPasscodeSettingsViewController.swift
//  Depo
//
//  Created by Yaroslav Bondar on 03/10/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

enum PasscodeSettingsViewState {
    case set
    case ready
}

class PasscodeSettingsViewController: UIViewController {
    var output: PasscodeSettingsViewOutput!
    
    @IBOutlet weak var passcodeView: UIView!
    @IBOutlet weak var changePasscodeView: UIView!
    @IBOutlet weak var touchIdView: UIView!
    @IBOutlet weak var setPasscodeView: UIView!
    
    @IBOutlet weak var passcodeSwitch: UISwitch!
    @IBOutlet weak var touchIdSwitch: UISwitch!
    
    var isAvailableTouchId = false
    let touchIdManager = TouchIdManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTitle(withString: "Passcode")
        isAvailableTouchId = touchIdManager.isAvailable
        output.viewIsReady()
        

    }
    
    let storage = PasscodeStorageDefaults()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if storage.isEmpty {
            setup(state: .set)
        } else {
            setup(state: .ready)
        }
        
        passcodeSwitch.isOn = !PasscodeStorageDefaults().isEmpty
        touchIdSwitch.isOn = touchIdManager.isEnabledTouchId
    }

    
    @IBAction func actionChangePasscodeButton(_ sender: UIButton) {
        let vc = PasscodeEnterViewController.with(flow: .setNew)
        vc.success = {
            RouterVC().navigationController?.popViewController(animated: true)
        }
        RouterVC().pushViewController(viewController: vc)
//        output.changePasscode()
    }
    
    @IBAction func actionPasscodeSwitch(_ sender: UISwitch) {
        setup(state: .set)
        storage.clearPasscode()
//        output.turnOffPasscode()
    }
    
    @IBAction func actionTouchIdSwitch(_ sender: UISwitch) {
        output.setTouchId(enable: sender.isOn)
    }
    @IBAction func actionSetPasscodeButton(_ sender: UIButton) {
        let vc = PasscodeEnterViewController.with(flow: .create)
        vc.success = {
            RouterVC().navigationController?.popViewController(animated: true)
        }
        RouterVC().pushViewController(viewController: vc)
//        output.setPasscode()
    }
}

// MARK: PasscodeSettingsViewInput
extension PasscodeSettingsViewController: PasscodeSettingsViewInput {
    func setup(state: PasscodeSettingsViewState) {
        
        switch state {
        case .set:
            passcodeView.isHidden = true
            changePasscodeView.isHidden = true
            touchIdView.isHidden = true
            setPasscodeView.isHidden = false
            
        case .ready:
            passcodeView.isHidden = false
            changePasscodeView.isHidden = false
            touchIdView.isHidden = !isAvailableTouchId
            setPasscodeView.isHidden = true
        }
    }
}
