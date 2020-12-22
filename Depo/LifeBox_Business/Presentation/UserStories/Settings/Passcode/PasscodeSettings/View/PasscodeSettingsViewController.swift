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

final class PasscodeSettingsViewController: ViewController {
    var output: PasscodeSettingsViewOutput!
    
    @IBOutlet weak var passcodeView: UIView!
    @IBOutlet weak var changePasscodeView: UIView!
    @IBOutlet weak var touchIdView: UIView!
    @IBOutlet weak var setPasscodeView: UIView!
    
    @IBOutlet weak var passcodeSwitch: UISwitch!
    @IBOutlet weak var biometricsSwitch: UISwitch!
    
    @IBOutlet weak var passcodeLabel: UILabel! {
        didSet {
            passcodeLabel.font = UIFont.TurkcellSaturaRegFont(size: 18)
            passcodeLabel.textColor = ColorConstants.textGrayColor
            passcodeLabel.text = TextConstants.passcode
        }
    }
    
    @IBOutlet weak var biometricsLabel: UILabel! {
        didSet {
            biometricsLabel.font = UIFont.TurkcellSaturaRegFont(size: 18)
            biometricsLabel.textColor = ColorConstants.textGrayColor
        }
    }
    
    @IBOutlet weak var biometricsErrorLabel: UILabel! {
        didSet {
            biometricsErrorLabel.font = UIFont.TurkcellSaturaRegFont(size: 16)
            biometricsErrorLabel.textColor = ColorConstants.textGrayColor
        }
    }
    
    @IBOutlet weak var changePasscodeLabel: UILabel! {
        didSet {
            changePasscodeLabel.font = UIFont.TurkcellSaturaRegFont(size: 18)
            changePasscodeLabel.textColor = ColorConstants.textGrayColor
            changePasscodeLabel.text = TextConstants.passcodeSettingsChangeTitle
        }
    }

    @IBOutlet weak var setPasscodeLabel: UILabel! {
        didSet {
            setPasscodeLabel.font = UIFont.TurkcellSaturaRegFont(size: 18)
            setPasscodeLabel.textColor = ColorConstants.textGrayColor
            setPasscodeLabel.text = TextConstants.passcodeSettingsSetTitle
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTexts()
        output.viewIsReady()
    }
    
    private lazy var biometricsTitle: String = {
        output.isAvailableFaceID ? TextConstants.passcodeFaceID : TextConstants.passcodeTouchID
    }()
    
    private func setupTexts() {
        setTitle(withString: TextConstants.passcodeLifebox)
        
        let enableText = TextConstants.passcodeEnable + " " + biometricsTitle
        biometricsLabel.text = enableText
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        output.isPasscodeEmpty ? setup(state: .set) : setup(state: .ready)
        
        switch output.biometricsStatus {
        case .available:
            touchIdView.isHidden = false
            biometricsSwitch.isEnabled = true
            biometricsErrorLabel.text = ""
        case .notAvailable:
            touchIdView.isHidden = true
        case .notInitialized:
            touchIdView.isHidden = false
            biometricsSwitch.isEnabled = false
            biometricsErrorLabel.text = String(format: TextConstants.passcodeBiometricsError, biometricsTitle)
        }
        
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
    
    func presentMailVerification() {
        let mailController = MailVerificationViewController()
        mailController.actionDelegate = self
        mailController.modalPresentationStyle = .overFullScreen
        mailController.modalTransitionStyle = .crossDissolve
        self.present(mailController, animated: true, completion: nil)

    }
}
// MARK: - mail verification
extension PasscodeSettingsViewController: MailVerificationViewControllerDelegate {
    func mailVerified(mail: String) {
        debugPrint("mail verified")
        output.mailVerified()
    }
    
    func mailVerificationFailed() {
        
    }
}
