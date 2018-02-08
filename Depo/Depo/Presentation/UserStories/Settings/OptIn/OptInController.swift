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

final class OptInController: UIViewController {

    @IBOutlet var keyboardHideManager: KeyboardHideManager!
    
    @IBOutlet weak var codeTextField: CodeTextField!
    @IBOutlet weak var timerLabel: SmartTimerLabel!
    @IBOutlet weak var resendButton: BlueButtonWithWhiteText!
    @IBOutlet weak var nextButton: BlueButtonWithWhiteText!
    @IBOutlet weak var titleLabel: UILabel!
    
    static func with(phone: String) -> OptInController {
        let vc = OptInController(nibName: "OptInController", bundle: nil)
        vc.phone = phone
        return vc
    }
    
    private lazy var activityManager = ActivityIndicatorManager()
    var phone = ""
    weak var delegate: OptInControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        navigationBarWithGradientStyle()
        
        automaticallyAdjustsScrollViewInsets = false
        
        codeTextField.becomeFirstResponder()
        setupTimer(withRemainingTime: NumericConstants.vereficationTimerLimit)
        
        nextButton.isEnabled = false
        nextButton.setTitle(TextConstants.otpNextButton, for: .normal)
        
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
    
    func setupTimer(withRemainingTime remainingTime: Int) {
        timerLabel.setupTimer(withTimeInterval: 1.0,
                              timerLimit: remainingTime)
        timerLabel.delegate = self
    }
    
    func dropTimer() {
        timerLabel.dropTimer()
    }
    
    @IBAction func changedCodeTextField(_ sender: CodeTextField) {
        if let code = sender.text, code.count >= sender.inputTextLimit, !timerLabel.isDead {
            verify(code: code)
        } else {
//            vereficationCodeNotReady()
        }
    }
    
    @IBAction func actionResendButton(_ sender: UIButton) {
        attempts = 0
        delegate?.optInResendPressed(self)
    }
    
    var attempts: Int = 0
    
    func verify(code: String) {
        delegate?.optIn(self, didEnterCode: code)
    }
    
    func clearCode() {
        codeTextField.text = ""
    }
    
    func showResendButton() {
        resendButton.isHidden = false
        nextButton.isHidden = true
    }
    
    func hideResendButton() {
        resendButton.isHidden = true
        nextButton.isHidden = false
    }
    
//    func vereficationCodeNotReady() {
//
//    }
    
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
