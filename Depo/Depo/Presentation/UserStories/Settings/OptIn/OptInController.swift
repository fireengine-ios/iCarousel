//
//  OptInController.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 11/27/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

protocol OptInControllerDelegate: class {
    func optInNavigationTitle() -> String
    func optInResendPressed(_ optInVC: OptInController)
    func optIn(_ optInVC: OptInController, didEnterCode code: String)
    func optInReachedMaxAttempts(_ optInVC: OptInController)
}

final class OptInController: ViewController, NibInit {

    static func with(phone: String) -> OptInController {
        let vc = OptInController.initFromNib()
        vc.phone = phone
        return vc
    }
    
    @IBOutlet private var keyboardHideManager: KeyboardHideManager!
    
    @IBOutlet private weak var codeTextField: CodeTextField!
    @IBOutlet private weak var timerLabel: SmartTimerLabel!
    @IBOutlet private weak var resendButton: BlueButtonWithWhiteText!
    @IBOutlet private weak var titleLabel: UILabel!
    
    private lazy var activityManager = ActivityIndicatorManager()
    private var phone = ""
    private var attempts: Int = 0
    
    weak var delegate: OptInControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        
        codeTextField.becomeFirstResponder()
        setupTimer(withRemainingTime: NumericConstants.vereficationTimerLimit)
        
        hideResendButton()
        resendButton.setTitle(TextConstants.otpResendButton, for: .normal)
        
        titleLabel.text = String(format: TextConstants.otpTitleText, phone)
        titleLabel.textColor = ColorConstants.textGrayColor
        titleLabel.font = UIFont.TurkcellSaturaRegFont(size: 18)
        
        timerLabel.textColor = ColorConstants.darkText
        timerLabel.font = UIFont.TurkcellSaturaBolFont(size: 39)
        
        if let delegate = delegate {
            setTitle(withString: delegate.optInNavigationTitle())
        }
        
        activityManager.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarWithGradientStyle()
    }
    
    override var preferredNavigationBarStyle: NavigationBarStyle {
        return .clear
    }
    
    func setupTimer(withRemainingTime remainingTime: Int) {
        timerLabel.setupTimer(withTimeInterval: 1.0,
                              timerLimit: remainingTime)
        timerLabel.delegate = self
    }
    
    func dropTimer() {
        timerLabel.dropTimer()
    }
    
    /// maybe will be need vereficationCodeNotReady in else
    @IBAction func changedCodeTextField(_ sender: CodeTextField) {
        if let code = sender.text, code.count >= sender.inputTextLimit, !timerLabel.isDead {
            verify(code: code)
        }
    }
    
    @IBAction func actionResendButton(_ sender: UIButton) {
        attempts = 0
        delegate?.optInResendPressed(self)
    }
    
    func verify(code: String) {
        delegate?.optIn(self, didEnterCode: code)
    }
    
    func clearCode() {
        codeTextField.text = ""
    }
    
    func showResendButton() {
        resendButton.isHidden = false
    }
    
    func hideResendButton() {
        resendButton.isHidden = true
    }
    
    func increaseNumberOfAttemps() -> Bool {
        attempts += 1
        
        if attempts >= NumericConstants.maxVereficationAttempts {
            attempts = 0
            endEnterCode()
            delegate?.optInReachedMaxAttempts(self)
            return true
        }
        return false
    }
    
    private func endEnterCode() {
        keyboardHideManager.dismissKeyboard()
        codeTextField.isEnabled = false
    }
    
    func startEnterCode() {
        codeTextField.isEnabled = true
        codeTextField.becomeFirstResponder()
    }
}

// MARK: - SmartTimerLabelDelegate
extension OptInController: SmartTimerLabelDelegate {
    func timerDidFinishRunning() {
        endEnterCode()
        clearCode()
        showResendButton()
    }
}

// MARK: - ActivityIndicator
extension OptInController: ActivityIndicator {
    func startActivityIndicator() {
        activityManager.start()
    }
    
    func stopActivityIndicator() {
        activityManager.stop()
    }
}
