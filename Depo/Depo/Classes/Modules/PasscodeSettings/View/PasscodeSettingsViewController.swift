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
    @IBOutlet weak var biometricsSwitch: UISwitch!
    @IBOutlet weak var biometricsLabel: UILabel!
    
    var isAvailableTouchId = false
    let touchIdManager = TouchIdManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTitle(withString: TextConstants.passcode)
        isAvailableTouchId = touchIdManager.isAvailable
        output.viewIsReady()
        
        let biometricsText = touchIdManager.isAvailableFaceID ? TextConstants.passcodeEnableFaceID : TextConstants.passcodeEnableTouchID
        biometricsLabel.text = biometricsText
    }
    
    let storage = PasscodeStorageDefaults()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        storage.isEmpty ? setup(state: .set) : setup(state: .ready)
        
        passcodeSwitch.isOn = !PasscodeStorageDefaults().isEmpty
        biometricsSwitch.isOn = touchIdManager.isEnabledBiometrics
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
        setup(state: .set, animated: true)
        storage.clearPasscode()
//        output.turnOffPasscode()
    }
    
    @IBAction func actionBiometricsSwitch(_ sender: UISwitch) {
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
//    func setup(state: PasscodeSettingsViewState) {
//        
//    }
    func setup(state: PasscodeSettingsViewState, animated: Bool = false) {
        
        let animateTime = animated ? NumericConstants.animationDuration : 0
        
        switch state {
        case .set:
            let views: [UIView] = [passcodeView, changePasscodeView, touchIdView]
            views.forEach {
                $0.transform = .identity
                $0.alpha = 1
            }
            self.setPasscodeView.transform = CGAffineTransform(translationX: 0, y: 50)
            self.setPasscodeView.alpha = 0
            self.touchIdView.isHidden = !self.isAvailableTouchId
            
            UIView.animate(withDuration: animateTime) {
                views.forEach {
                    $0.transform = CGAffineTransform(translationX: 0, y: 50)
                    $0.alpha = 0
                }
                self.setPasscodeView.transform = .identity
                self.setPasscodeView.alpha = 1
            }
            
        case .ready:
            
            let views: [UIView] = [passcodeView, changePasscodeView, touchIdView]
            views.forEach {
                $0.transform = CGAffineTransform(translationX: 0, y: 50)
                $0.alpha = 0
            }
            self.setPasscodeView.transform = .identity
            self.setPasscodeView.alpha = 1
            self.touchIdView.isHidden = !self.isAvailableTouchId
            
            UIView.animate(withDuration: animateTime) {
                views.forEach {
                    $0.transform = .identity
                    $0.alpha = 1
                }
                self.setPasscodeView.transform = CGAffineTransform(translationX: 0, y: 50)
                self.setPasscodeView.alpha = 0
            }
        }
    }
}
