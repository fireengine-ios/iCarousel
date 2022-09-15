//
//  PhoneVerificationPhoneVerificationViewController.swift
//  Depo
//
//  Created by AlexanderP on 14/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit
import Typist

class PhoneVerificationViewController: ViewController, PhoneVerificationViewInput {
    
    private enum Constants {
        static let timerLabelBottomOffset: CGFloat = 18
        static let timelLabelTopOffset: CGFloat = 56
    }
    
    var output: PhoneVerificationViewOutput!
        
    @IBOutlet private weak var scrollView: UIScrollView!
    
    @IBOutlet private weak var timerLabel: SmartTimerLabel!
        
    @IBOutlet private weak var mainTitle: UILabel!
    
    @IBOutlet private weak var infoTitle: UILabel!
    
    @IBOutlet private weak var firstSecurityCodeTextField: SecurityCodeTextField!
    
    @IBOutlet private weak var errorLabel: UILabel!
    @IBOutlet private weak var bottomTimerConstraint: NSLayoutConstraint!
    
    @IBOutlet private var codeTextFields: [SecurityCodeTextField]!
        
    @IBOutlet weak var continueButton: RoundedInsetsButton! {
        willSet {
            newValue.adjustsFontSizeToFitWidth()
            newValue.setTitle(localized(.resetPasswordContinueButton), for: .normal)
            newValue.setTitleColor(.white, for: .normal)
            newValue.titleLabel?.font = .appFont(.medium, size: 16)
            newValue.setBackgroundColor(AppColor.forgetPassButtonNormal.color, for: .normal)
            newValue.setBackgroundColor(AppColor.forgetPassButtonDisable.color, for: .disabled)
            newValue.layer.borderColor = AppColor.forgetPassButtonNormal.cgColor
            newValue.isUserInteractionEnabled = true
            newValue.isEnabled = true
            newValue.isOpaque = true
        }
    }
    
    @IBOutlet private weak var resendCodeButton: UIButton! {
        willSet {
            newValue.adjustsFontSizeToFitWidth()
            newValue.setTitle(TextConstants.resendCode, for: .normal)
            newValue.setTitleColor(AppColor.forgetPassText.color, for: .normal)
            newValue.titleLabel?.font = .appFont(.medium, size: 14)
            newValue.setBackgroundColor(AppColor.primaryBackground.color, for: .normal)
            newValue.isOpaque = true
        }
    }
    
    var inputTextLimit: Int = NumericConstants.verificationCharacterLimit
        
    private let keyboard = Typist()
    
    private var isRemoveLetter: Bool = false

    private var timerEnabled: Bool = true
    
    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupKeyboard()
    
        output.viewIsReady()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if isMovingFromParent {
            output.userNavigatedBack()
        }
    }
    
    @IBAction func continueButton(_ sender: UIButton) {
        output.verificationCodeEntered()
    }
    @IBAction func resendCode(_ sender: Any) {
        hiddenError()
        output.resendButtonPressed()
    }

    @objc private func textFieldDidChange(_ sender: UITextField) {
        if isRemoveLetter {
            let previosTag = sender.tag - 1
            if let nextResponder = codeTextFields[safe: previosTag] {
                nextResponder.layer.borderColor = AppColor.forgetPassCodeClose.cgColor
                /// For autoFill one time password
                if previosTag <= 0 {
                    nextResponder.text = ""
                }
                
                nextResponder.becomeFirstResponder()
            }
        } else {
            codeTextFields[safe: sender.tag]?.layer.borderColor = AppColor.forgetPassCodeOpen.cgColor
            let nextTag = sender.tag + 1
            if let nextResponder = codeTextFields[safe: nextTag] {
                nextResponder.becomeFirstResponder()
            } else {
                hideKeyboard()
            }
        }
    }
    
    fileprivate func hideKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: Setup keyboard
    private func setupKeyboard() {
        keyboard
            .on(event: .willShow) { [weak self] options in
                guard let `self` = self else {
                    return
                }
                
                self.updateScroll(with: options.endFrame)
            }
            .on(event: .didShow) { [weak self] options in
                guard let `self` = self else {
                    return
                }
                
                UIView.animate(withDuration: options.animationDuration) {
                    self.bottomTimerConstraint?.constant = options.endFrame.height + Constants.timerLabelBottomOffset

                    self.view.layoutIfNeeded()
                }
                
                if let viewToScroll = (self.errorLabel.isHidden ? self.firstSecurityCodeTextField : self.errorLabel) {
                    ///convertion work correctly with firstSecurityCodeTextField-firstSecurityCodeTextField pair
                    ///and
                    ///errorLabel-view pair
                    let convertParent = viewToScroll is UILabel ? self.view : self.firstSecurityCodeTextField
                    
                    let rectToShow = convertParent?.convert(viewToScroll.frame, to: self.view) ?? .zero
                    let rectToShowWithInset = rectToShow.offsetBy(dx: 0, dy: Constants.timelLabelTopOffset)
                    
                    self.scrollView.scrollRectToVisible(rectToShowWithInset, animated: true)
                } else {
                    assertionFailure()
                }
            }
            .on(event: .willHide) { [weak self] options in
                guard let `self` = self else {
                    return
                }
                
                UIView.animate(withDuration: options.animationDuration) {
                    self.bottomTimerConstraint?.constant =  Constants.timerLabelBottomOffset
                    
                    var inset = self.scrollView.contentInset
                    inset.bottom = 0
                    self.scrollView.contentInset = inset
                    self.scrollView.scrollIndicatorInsets = inset
                    
                    self.view.layoutIfNeeded()
                }
            }
            .start()
    }
    
    private func updateScroll(with keyboardFrame: CGRect) {
        let bottomInset = keyboardFrame.height - scrollView.safeAreaInsets.bottom
        
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
        self.scrollView.contentInset = insets
        self.scrollView.scrollIndicatorInsets = insets
    }
    
    private func hiddenError() {
        errorLabel.text = ""
        errorLabel.isHidden = true
    }
    
    // MARK: PhoneVerificationViewInput
    func setupInitialState(timerEnabled: Bool) {
        codeTextFields.forEach({
            $0.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        })
        
        firstSecurityCodeTextField.becomeFirstResponder()
        
        mainTitle.font = .appFont(.regular, size: 15)
        mainTitle.textColor = AppColor.forgetPassText.color
        
        infoTitle.font = .appFont(.medium, size: 14)
        infoTitle.text = TextConstants.phoneVerificationInfoTitleText
        infoTitle.textColor = AppColor.forgetPassText.color
        infoTitle.textAlignment = .left
        
        timerLabel.isHidden = true
        
        timerLabel.font = .appFont(.medium, size: 14)
        timerLabel.textColor = AppColor.forgetPassTimer.color
        timerLabel.setContentCompressionResistancePriority(.required, for: .vertical)
      
        errorLabel.textColor = ColorConstants.textOrange
        errorLabel.font = .appFont(.regular, size: 16)

        self.timerEnabled = timerEnabled
    }
    
    func setupButtonsInitialState() {
        resendButtonShow(show: false)
    }
    
    func setupTimer(withRemainingTime remainingTime: Int) {
        timerLabel.isHidden = false
        timerLabel.setupTimer(withTimeInterval: 1.0,
                                   timerLimit: remainingTime)
        timerLabel.delegate = self
    }
    
    func dropTimer() {
        timerLabel.dropTimer()
    }
    
    func resendButtonShow(show: Bool) {
        resendCodeButton.isHidden = !show
        resendCodeButton.isEnabled = show
    }
    
    func setupTextLengh(lenght: Int) {
         inputTextLimit = lenght
    }
    
    func setupPhoneLable(with textDescription: String, number: String) {
        let text = String(format: textDescription, number)
        let range = (text as NSString).range(of: number)
        let attr: [NSAttributedString.Key: Any] = [
            .font: UIFont.appFont(.medium, size: 15),
            .foregroundColor: AppColor.forgetPassText.color
        ]
        
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttributes(attr, range: range)
        infoTitle.attributedText = attributedString
    }

    func setupTitleText(title: String, subTitle: String) {
        if !Device.isIpad {
            setNavigationTitle(title: title)
        }

        mainTitle.text = subTitle
    }
    
    func getNavigationController() -> UINavigationController? {
        return self.navigationController
    }
    
    func updateEditingState() {
        codeTextFields.forEach({
            $0.text = ""
            $0.layer.borderColor = AppColor.forgetPassCodeClose.cgColor
        })
        
        timerLabel.isHidden = !resendCodeButton.isHidden || !timerEnabled
        
        output.clearCurrentSecurityCode()
        
        if resendCodeButton.isHidden {
            firstSecurityCodeTextField.becomeFirstResponder()
        } else {
            hideKeyboard()
        }
    }
    
    func showError(_ error: String) {
        errorLabel.isHidden = false
        continueButton.isEnabled = false
        errorLabel.text = error
    }
}

// MARK: - UITextFieldDelegate, SmartTimerLabelDelegate
extension PhoneVerificationViewController: UITextFieldDelegate, SmartTimerLabelDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        /// For autoFill one time password
        if firstSecurityCodeTextField == textField {
            return
        }
        
        /// if the string is empty, then when deleting, the delegate method does not work
        textField.text = " "
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        isRemoveLetter = string.isEmpty

        if string.isEmpty {
            output.currentSecurityCodeRemoveCharacter()
            
            return true
        } 
        
        /// clear the space that we added to work delegate methods with an empty string
        textField.text = ""
        
        hiddenError()
        
        let notAvailableCharacterSet = CharacterSet.decimalDigits.inverted
        let result = string.rangeOfCharacter(from: notAvailableCharacterSet)
        if ( result != nil) {
            return false
        }
        
        let currentStr = output.currentSecurityCode + string
        
        if currentStr.count == inputTextLimit, (!timerLabel.isDead || !timerEnabled) {
            output.currentSecurityCodeChanged(with: string)
            continueButton.isEnabled = true
            return true
        } else if currentStr.count > inputTextLimit {
            return false
        } else {
            output.verificationCodeNotReady()
        }

        output.currentSecurityCodeChanged(with: string)
        
        return true
    }
    
    func timerDidFinishRunning() {
        output.timerFinishedRunning(with: timerLabel.isShowMessageWithDropTimer)
        timerLabel.isShowMessageWithDropTimer = true
        continueButton.isEnabled = false
    }
}
