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

final class PasscodeSettingsViewController: BaseViewController {
    var output: PasscodeSettingsViewOutput!
    
    @IBOutlet weak var passcodeView: UIView!
    @IBOutlet weak var changePasscodeView: UIView!
    @IBOutlet weak var touchIdView: UIView!
    @IBOutlet weak var setPasscodeView: UIView! {
        willSet {
            newValue.backgroundColor = AppColor.secondaryBackground.color
            newValue.addRoundedShadows(cornerRadius: 16,
                                       shadowColor: AppColor.filesBigCellShadow.cgColor,
                                       opacity: 0.4, radius: 4.0)
        }
    }
    
    @IBOutlet weak var passcodeSwitch: UISwitch!
    @IBOutlet weak var biometricsSwitch: UISwitch!
    
    @IBOutlet weak var passcodeLabel: UILabel! {
        didSet {
            passcodeLabel.font = .appFont(.regular, size: 14)
            passcodeLabel.textColor = AppColor.label.color
            passcodeLabel.text = TextConstants.passcode
        }
    }
    
    @IBOutlet weak var biometricsLabel: UILabel! {
        didSet {
            biometricsLabel.font = .appFont(.regular, size: 14)
            biometricsLabel.textColor = AppColor.label.color
        }
    }
    
    @IBOutlet weak var biometricsErrorLabel: UILabel! {
        didSet {
            biometricsErrorLabel.font = .appFont(.regular, size: 12)
            biometricsErrorLabel.textColor = AppColor.label.color
        }
    }
    
    @IBOutlet weak var changePasscodeLabel: UILabel! {
        didSet {
            changePasscodeLabel.font = .appFont(.regular, size: 14)
            changePasscodeLabel.textColor = AppColor.label.color
            changePasscodeLabel.text = TextConstants.passcodeSettingsChangeTitle
        }
    }

    @IBOutlet weak var setPasscodeLabel: UILabel! {
        didSet {
            setPasscodeLabel.font = .appFont(.regular, size: 14)
            setPasscodeLabel.textColor = AppColor.label.color
            setPasscodeLabel.text = TextConstants.passcodeSettingsSetTitle
        }
    }
    
    @IBOutlet private weak var passcodeStackView: UIStackView! {
        willSet {
            newValue.backgroundColor = AppColor.secondaryBackground.color
            newValue.addRoundedShadows(cornerRadius: 16,
                                       shadowColor: AppColor.filesBigCellShadow.cgColor,
                                       opacity: 0.4, radius: 4.0)
        }
    }
    
    @IBOutlet private weak var twoFactorAuthView: UIView! {
        willSet {
            newValue.backgroundColor = AppColor.secondaryBackground.color
            newValue.addRoundedShadows(cornerRadius: 16,
                                       shadowColor: AppColor.filesBigCellShadow.cgColor,
                                       opacity: 0.4, radius: 4.0)
        }
    }
    
    @IBOutlet weak var twoFactorAuthDescriptionLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.loginSettingsTwoFactorAuthDescription
            newValue.textColor = AppColor.label.color
            newValue.font = .appFont(.regular, size: 12)
        }
    }
    
    @IBOutlet weak var twoFactorAuthLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.settingsViewCellTwoFactorAuth
            newValue.textColor = AppColor.label.color
            newValue.font = .appFont(.regular, size: 14)
        }
    }
    
    @IBOutlet weak var twoFactorAuthSwitchj: GradientSwitch!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTexts()
        output.viewIsReady()
    }
    
    private lazy var biometricsTitle: String = {
        output.isAvailableFaceID ? TextConstants.passcodeFaceID : TextConstants.passcodeTouchID
    }()
    
    private func setupTexts() {
        let enableText = TextConstants.passcodeEnable + " " + biometricsTitle
        biometricsLabel.text = enableText
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setTitle(withString: TextConstants.settingsViewCellLoginSettings)
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
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        passcodeStackView.addRoundedShadows(cornerRadius: 16,
                                            shadowColor: AppColor.filesBigCellShadow.cgColor,
                                            opacity: 0.4, radius: 4.0)
        setPasscodeView.addRoundedShadows(cornerRadius: 16,
                                            shadowColor: AppColor.filesBigCellShadow.cgColor,
                                            opacity: 0.4, radius: 4.0)
        twoFactorAuthView.addRoundedShadows(cornerRadius: 16,
                                   shadowColor: AppColor.filesBigCellShadow.cgColor,
                                   opacity: 0.4, radius: 4.0)

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
    
    @IBAction func actionTwoFactorSwitch(_ sender: UISwitch) {
        output.updatedTwoFactorAuth(isEnabled: sender.isOn)
    }
    
}

// MARK: PasscodeSettingsViewInput
extension PasscodeSettingsViewController: PasscodeSettingsViewInput {
    func setup(state: PasscodeSettingsViewState, animated: Bool = false) {
        
        let animateTime = animated ? NumericConstants.animationDuration : 0
        let views: [UIView] = [passcodeStackView]
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
    
    func updatedTwoFactorAuth(isEnabled: Bool) {
        twoFactorAuthSwitchj.isOn = isEnabled
    }
}
