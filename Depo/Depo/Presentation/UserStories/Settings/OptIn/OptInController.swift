//
//  OptInController.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 11/27/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit
import Typist

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
    
    private enum Constants {
        static let timerLabelBottomOffset: CGFloat = 8
    }
        
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
    
    private lazy var activityManager = ActivityIndicatorManager()
    private var phone = ""
    private var attempts: Int = 0
    private let keyboard = Typist()
    private var currentSecurityCode = ""
    private var inputTextLimit: Int = NumericConstants.vereficationCharacterLimit
    private var isRemoveLetter: Bool = false

    
    weak var delegate: OptInControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupKeyboard()
        setupButtonsInitialState()
        setupTimer(withRemainingTime: NumericConstants.vereficationTimerLimit)
        setupInitialState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavBar()
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
    
    @IBAction func actionResendButton(_ sender: UIButton) {
        attempts = 0
        delegate?.optInResendPressed(self)
    }
    
    func verify(code: String) {
        delegate?.optIn(self, didEnterCode: code)
    }
    
    func clearCode() {
        codeTextFields.forEach({
            $0.text = ""
        })
        currentSecurityCode = ""
    }
    
    func showResendButton() {
        resendCodeButton.isHidden = false
        hideKeyboard()
    }
    
    func hideResendButton() {
        resendCodeButton.isHidden = true
        firstSecurityCodeTextField.becomeFirstResponder()
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
    
    func startEnterCode() {
        firstSecurityCodeTextField.becomeFirstResponder()
    }
    
    func showError(_ showTextError: String) {
        errorLabel.isHidden = false
        errorLabel.text = showTextError
    }
    
    func hiddenError() {
        errorLabel.text = ""
        errorLabel.isHidden = true
    }
    
    // MARK: - Utility methods
    private func setupNavBar() {
        navigationBarWithGradientStyle()
        backButtonForNavigationItem(title: TextConstants.backTitle)
    }
    
    private func setupInitialState() {
        codeTextFields.forEach({
            $0.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        })
        
        startEnterCode()
        
        setupPhoneLable(with: phone)
        
        if !Device.isIpad {
            setNavigationTitle(title: TextConstants.enterSecurityCode)
        }
        navigationItem.backBarButtonItem?.title = TextConstants.backTitle
        
        mainTitle.font = UIFont.TurkcellSaturaRegFont(size: 35)
        mainTitle.textColor = .black
        mainTitle.text = TextConstants.enterSecurityCode
        
        infoTitle.font = UIFont.TurkcellSaturaMedFont(size: 15)
        infoTitle.textColor = ColorConstants.blueGrey
        
        timerLabel.font = UIFont.TurkcellSaturaRegFont(size: 35)
        timerLabel.textColor = ColorConstants.cloudyBlue
        
        errorLabel.textColor = ColorConstants.textOrange
        errorLabel.font = UIFont.TurkcellSaturaDemFont(size: 16)
    }
    
    private func setupButtonsInitialState() {
        resendCodeButton.isHidden = true
    }
    
    func setupPhoneLable(with number: String) {
        let text = String(format: TextConstants.enterCodeToGetCodeOnPhone, number)
        let range = (text as NSString).range(of: number)
        let attr: [NSAttributedStringKey: Any] = [.font: UIFont.TurkcellSaturaMedFont(size: 15),
                                                  .foregroundColor: ColorConstants.textGrayColor]
        
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttributes(attr, range: range)
        infoTitle.attributedText = attributedString
    }
    
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
    
    private func endEnterCode() {
        hideKeyboard()
    }
    
    fileprivate func hideKeyboard() {
        view.endEditing(true)
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
    
}

// MARK: - SmartTimerLabelDelegate
extension OptInController: SmartTimerLabelDelegate {
    func timerDidFinishRunning() {
        endEnterCode()
        clearCode()
        showResendButton()
        
        if timerLabel.isShowMessageWithDropTimer {
            showError(TextConstants.timeIsUpForCode)
        }

        timerLabel.isShowMessageWithDropTimer = true
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

// MARK: - UITextFieldDelegate
extension OptInController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        /// if the string is empty, then when deleting, the delegate method does not work
        textField.text = " "
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        isRemoveLetter = string.isEmpty

        if string.isEmpty {
            if !currentSecurityCode.isEmpty {
                currentSecurityCode.removeLast()
            }
            
            return true
        } 
        
        /// clear the space that we added to work delegate methods with an empty string
        textField.text = ""
        
        hiddenError()
        let notAvailableCharacterSet = CharacterSet.decimalDigits.inverted
        let result = string.rangeOfCharacter(from: notAvailableCharacterSet)
        if result != nil {
            return false
        }
        
        let currentСodeEntered = currentSecurityCode + string
        
        if currentСodeEntered.count == inputTextLimit,
            !timerLabel.isDead {
            currentSecurityCode = currentСodeEntered
            verify(code: currentSecurityCode)
            return true
        } else if currentСodeEntered.count > inputTextLimit {
            return false
        }
        
        currentSecurityCode = currentSecurityCode + string
        
        return true
    }
    
}

