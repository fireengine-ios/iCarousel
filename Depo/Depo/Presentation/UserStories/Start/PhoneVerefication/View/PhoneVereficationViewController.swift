//
//  PhoneVereficationPhoneVereficationViewController.swift
//  Depo
//
//  Created by AlexanderP on 14/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit
import Typist

class PhoneVereficationViewController: ViewController, PhoneVereficationViewInput {
    
    private enum Constants {
        static let timerLabelBottomOffset: CGFloat = 8
    }
    
    var output: PhoneVereficationViewOutput!
        
    @IBOutlet private weak var timerLabel: SmartTimerLabel!
        
    @IBOutlet private weak var mainTitle: UILabel!
    
    @IBOutlet private weak var infoTitle: UILabel!
    
    @IBOutlet private weak var firstSecurityCodeTextField: SecurityCodeTextField!
    
    @IBOutlet private weak var errorLabel: UILabel!
    @IBOutlet private weak var bottomTimerConstraint: NSLayoutConstraint!
    
    @IBOutlet private var codeTextFields: [SecurityCodeTextField]!
    
    @IBOutlet private weak var resendCodeButton: RoundedInsetsButton! {
        willSet {
            newValue.setTitle(TextConstants.resendCode, for: .normal)
            newValue.setTitleColor(UIColor.white, for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaDemFont(size: 18)
            newValue.backgroundColor = UIColor.lrTealish
            newValue.isOpaque = true
        }
    }
    
    var inputTextLimit: Int = NumericConstants.vereficationCharacterLimit
        
    private let keyboard = Typist()
    
    private var isRemoveLetter: Bool = false
    
    // MARK: Life cycle
    override var preferredNavigationBarStyle: NavigationBarStyle {
        return .clear
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupKeyboard()
    
        output.viewIsReady()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationBarWithGradientStyle()
    }
    
    @IBAction func ResendCode(_ sender: Any) {
        hiddenError()
        output.resendButtonPressed()
    }
    
    @objc private func textFieldDidChange(_ sender: UITextField) {
        if isRemoveLetter {
            let previosTag = sender.tag - 1
            if let nextResponder = codeTextFields[safe: previosTag] {
                nextResponder.becomeFirstResponder()
            }
        } else {
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
        keyboard.on(event: .willShow) { [weak self] (options) in
            UIView.animate(withDuration: options.animationDuration) {
                self?.bottomTimerConstraint?.constant = options.endFrame.height + Constants.timerLabelBottomOffset
                
                self?.view.layoutIfNeeded()
            }
            }.on(event: .willHide) { [weak self] (options) in
                UIView.animate(withDuration: options.animationDuration) {
                    self?.bottomTimerConstraint?.constant =  Constants.timerLabelBottomOffset
                    
                    self?.view.layoutIfNeeded()
                }
            }.start()
    }
    
    private func hiddenError() {
        errorLabel.text = ""
        errorLabel.isHidden = true
    }
    // MARK: PhoneVereficationViewInput
    
    func setupInitialState() {
        codeTextFields.forEach({
            $0.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        })
        
        firstSecurityCodeTextField.becomeFirstResponder()

        if !Device.isIpad {
            setNavigationTitle(title: TextConstants.enterSecurityCode)
        }
        navigationItem.backBarButtonItem?.title = TextConstants.backTitle
        
        mainTitle.font = UIFont.TurkcellSaturaRegFont(size: 35)
        mainTitle.textColor = .black
        mainTitle.text = TextConstants.enterSecurityCode
        infoTitle.font = UIFont.TurkcellSaturaRegFont(size: 18)
        infoTitle.text = TextConstants.phoneVereficationInfoTitleText
        timerLabel.isHidden = true
        
        infoTitle.font = UIFont.TurkcellSaturaMedFont(size: 15)
        infoTitle.textColor = ColorConstants.blueGrey
        
        timerLabel.font = UIFont.TurkcellSaturaRegFont(size: 35)
        timerLabel.textColor = ColorConstants.cloudyBlue
        
        errorLabel.textColor = ColorConstants.textOrange
        errorLabel.font = UIFont.TurkcellSaturaDemFont(size: 16)
    }
    
    func setupButtonsInitialState() {
        resendCodeButton.isHidden = true
        resendCodeButton.isEnabled = false
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
    
    func setupPhoneLable(with number: String) {
        let text = String(format: TextConstants.enterCodeToGetCodeOnPhone, number)
        let range = (text as NSString).range(of: number)
        let attr: [NSAttributedStringKey: AnyObject] = [NSAttributedStringKey.font: UIFont.TurkcellSaturaMedFont(size: 15),
                                                        NSAttributedStringKey.foregroundColor: ColorConstants.textGrayColor]
        
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttributes(attr, range: range)
        infoTitle.attributedText = attributedString
    }
    
    func getNavigationController() -> UINavigationController? {
        return self.navigationController
    }
    
    func updateEditingState() {
        codeTextFields.forEach({
            $0.text = ""
        })
        
        timerLabel.isHidden = !resendCodeButton.isHidden        
        
        output.clearCurrentSecurityCode()
        
        if resendCodeButton.isHidden {
            firstSecurityCodeTextField.becomeFirstResponder()
        } else {
            hideKeyboard()
        }
    }
    
    func showError(_ error: String) {
        errorLabel.isHidden = false
        errorLabel.text = error
    }
    
}

// MARK: - UITextFieldDelegate, SmartTimerLabelDelegate
extension PhoneVereficationViewController: UITextFieldDelegate, SmartTimerLabelDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
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
        
        if currentStr.count == inputTextLimit,
                !timerLabel.isDead {
            output.currentSecurityCodeChanged(with: string)
            output.vereficationCodeEntered()
            return true
        } else if currentStr.count > inputTextLimit {
            return false
        } else {
            output.vereficationCodeNotReady()
        }

        output.currentSecurityCodeChanged(with: string)
        
        return true
    }
    
    func timerDidFinishRunning() {
        output.timerFinishedRunning(with: timerLabel.isShowMessageWithDropTimer)
        timerLabel.isShowMessageWithDropTimer = true
    }
}
