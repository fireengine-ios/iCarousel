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
    
    var biometricsIsAvailable = false {
        didSet {
            touchIdView.isHidden = !biometricsIsAvailable
        }
    }
    
    let storage = PasscodeStorageDefaults()
    let biometricsManager = BiometricsManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTitle(withString: TextConstants.passcode)
        output.viewIsReady()
        
        let biometricsText = biometricsManager.isAvailableFaceID ? TextConstants.passcodeEnableFaceID : TextConstants.passcodeEnableTouchID
        biometricsLabel.text = biometricsText
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        storage.isEmpty ? setup(state: .set) : setup(state: .ready)
        
        biometricsIsAvailable = biometricsManager.isAvailable
        passcodeSwitch.isOn = !PasscodeStorageDefaults().isEmpty
        biometricsSwitch.isOn = biometricsManager.isEnabled
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
}
