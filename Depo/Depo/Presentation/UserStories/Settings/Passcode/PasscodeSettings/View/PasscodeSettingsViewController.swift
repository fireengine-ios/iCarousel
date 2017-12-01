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

final class PasscodeSettingsViewController: UIViewController {
    var output: PasscodeSettingsViewOutput!
    
    @IBOutlet weak var passcodeView: UIView!
    @IBOutlet weak var changePasscodeView: UIView!
    @IBOutlet weak var touchIdView: UIView!
    @IBOutlet weak var setPasscodeView: UIView!
    
    @IBOutlet weak var passcodeSwitch: UISwitch!
    @IBOutlet weak var biometricsSwitch: UISwitch!
    @IBOutlet weak var biometricsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTitle(withString: TextConstants.passcode)
        
        let biometricsText = output.isAvailableFaceID ? TextConstants.passcodeEnableFaceID : TextConstants.passcodeEnableTouchID
        biometricsLabel.text = biometricsText
        
        output.viewIsReady()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        output.isPasscodeEmpty ? setup(state: .set) : setup(state: .ready)
        
        touchIdView.isHidden = !output.isBiometricsAvailable
        passcodeSwitch.isOn = !output.isPasscodeEmpty
        biometricsSwitch.isOn = output.isBiometricsEnabled
    }
    
    @IBAction func actionChangePasscodeButton(_ sender: UIButton) {
        output.changePasscode()
    }
    
    @IBAction func actionPasscodeSwitch(_ sender: UISwitch) {
        output.turnOffPasscode()
    }
    
    @IBAction func actionBiometricsSwitch(_ sender: UISwitch) {
        output.setTouchId(enable: sender.isOn)
    }
    
    @IBAction func actionSetPasscodeButton(_ sender: UIButton) {
        output.setPasscode()
    }
}

// MARK: PasscodeSettingsViewInput
extension PasscodeSettingsViewController: PasscodeSettingsViewInput {
    func setup(state: PasscodeSettingsViewState, animated: Bool = false) {
        
        let animateTime = animated ? NumericConstants.animationDuration : 0
        let views: [UIView] = [passcodeView, changePasscodeView, touchIdView]
        let animationTransform = CGAffineTransform(translationX: 0, y: 50)
        
        switch state {
        case .set:
            
            views.forEach {
                $0.transform = .identity
                $0.alpha = 1
            }
            self.setPasscodeView.transform = animationTransform
            self.setPasscodeView.alpha = 0
            
            UIView.animate(withDuration: animateTime) {
                views.forEach {
                    $0.transform = animationTransform
                    $0.alpha = 0
                }
                self.setPasscodeView.transform = .identity
                self.setPasscodeView.alpha = 1
            }
            
        case .ready:
            
            views.forEach {
                $0.transform = animationTransform
                $0.alpha = 0
            }
            self.setPasscodeView.transform = .identity
            self.setPasscodeView.alpha = 1
            
            UIView.animate(withDuration: animateTime) {
                views.forEach {
                    $0.transform = .identity
                    $0.alpha = 1
                }
                self.setPasscodeView.transform = animationTransform
                self.setPasscodeView.alpha = 0
            }
        }
    }
    
    func presentMailVerefication() {
        
        
        
    }
}
