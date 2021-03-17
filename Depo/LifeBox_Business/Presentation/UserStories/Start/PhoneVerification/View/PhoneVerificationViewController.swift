//
//  PhoneVerificationPhoneVerificationViewController.swift
//  Depo
//
//  Created by AlexanderP on 14/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit
import Typist

final class PhoneVerificationViewController: ViewController {
    
    private enum Constants {
        static let timerLabelBottomOffset: CGFloat = 8
        static let timelLabelTopOffset: CGFloat = 56
    }
    
    var output: PhoneVerificationViewOutput!

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var firstSecurityCodeTextField: OneSignSquareTextField!
    @IBOutlet private var codeTextFields: [OneSignSquareTextField]!
    @IBOutlet private var smartTimerProgressView: SmartTimerProgressView!

    @IBOutlet private weak var mainTitle: UILabel! {
        willSet {
            newValue.font = UIFont.GTAmericaStandardMediumFont(size: 18)
            newValue.textColor = ColorConstants.infoPageValueText
        }
    }

    @IBOutlet private weak var infoTitle: UILabel! {
        willSet {
            newValue.font = UIFont.GTAmericaStandardRegularFont(size: 14)
            newValue.textColor = ColorConstants.a2FADescriptionLabel
        }
    }


    @IBOutlet private weak var underTextfieldsLabel: UILabel! {
        willSet {
            newValue.font = UIFont.GTAmericaStandardMediumFont(size: 14)
            newValue.textColor = ColorConstants.infoPageValueText
        }
    }

    @IBOutlet private weak var errorLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.loginErrorLabelText
            newValue.font = UIFont.GTAmericaStandardRegularFont(size: 12)
            newValue.textAlignment = .center
        }
    }

    @IBOutlet private weak var scrollViewContainerView: UIView! {
        willSet {
            newValue.backgroundColor = ColorConstants.tableBackground
        }
    }

    @IBOutlet private weak var resendCodeActionButton: UIButton! {
        willSet {
            newValue.setTitle(TextConstants.resendCode, for: .normal)
            newValue.setTitleColor(UIColor.white, for: .normal)
            newValue.titleLabel?.font = UIFont.GTAmericaStandardMediumFont(size: 14)
            newValue.setBackgroundColor(ColorConstants.buttonDarkBlueBackground, for: .normal)
            newValue.layer.cornerRadius = 6
            newValue.isOpaque = true
        }
    }

    private var inputTextLimit: Int = NumericConstants.verificationCharacterLimit
    private let keyboard = Typist()
    private var isRemoveLetter: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConstants.tableBackground
        
        setupKeyboard()
    
        output.viewIsReady()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupNavigationBar()
    }

    private func setupNavigationBar() {
        title = TextConstants.a2FASecondPageSecurityCode
        defaultNavBarStyle()
//        whiteNavBarStyle(tintColor: ColorConstants.infoPageItemBottomText,
//                         titleTextColor: ColorConstants.infoPageItemBottomText)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.navigationBar.topItem?.backButtonTitle = ""
    }
    
    @IBAction func resendCode(_ sender: Any) {
        hideError()
        output.resendButtonPressed()
    }
    
    @objc private func textFieldDidChange(_ sender: UITextField) {
        if isRemoveLetter {
            let previosTag = sender.tag - 1
            if let nextResponder = codeTextFields[safe: previosTag] {
                /// For autoFill one time password
                if previosTag <= 0 {
                    nextResponder.text = ""
                }
                
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
    
    private func hideKeyboard() {
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
    
    private func hideError() {
        errorLabel.text = ""
        errorLabel.isHidden = true
    }
}

// MARK: - PhoneVerificationViewInput
extension PhoneVerificationViewController: PhoneVerificationViewInput {
    func configureTexts(navigationTitle: String?,
                        mainPageTitle: String,
                        infoTitle: String,
                        underTextfieldText: String) {
        title = navigationTitle
        mainTitle.text = mainPageTitle
        self.infoTitle.text = infoTitle
        underTextfieldsLabel.text = underTextfieldText
    }

    func setupInitialState() {
        codeTextFields.forEach({
            $0.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        })

        firstSecurityCodeTextField.becomeFirstResponder()
    }

    func setupButtonsInitialState() {
        resendButtonShow(show: false)
    }

    func setupTimer(withRemainingTime remainingTime: Int) {
        smartTimerProgressView.setupProgressViewWithTimer(timerLimit: remainingTime)
        smartTimerProgressView.delegate = self
    }

    func dropTimer() {
        smartTimerProgressView.dropTimer()
    }

    func resendButtonShow(show: Bool) {
        resendCodeActionButton.isHidden = !show
        resendCodeActionButton.isEnabled = show
    }

    func setupTextLengh(lenght: Int) {
         inputTextLimit = lenght
    }

    func setupPhoneLable(with textDescription: String, number: String) {
        let text = String(format: textDescription, number)
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

        output.clearCurrentSecurityCode()

        if resendCodeActionButton.isHidden {
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
extension PhoneVerificationViewController: UITextFieldDelegate {
    
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
        
        hideError()
        
        let notAvailableCharacterSet = CharacterSet.decimalDigits.inverted
        let result = string.rangeOfCharacter(from: notAvailableCharacterSet)
        if ( result != nil) {
            return false
        }
        
        let currentStr = output.currentSecurityCode + string
        
        if currentStr.count == inputTextLimit,
                !smartTimerProgressView.isDead {
            output.currentSecurityCodeChanged(with: string)
            output.verificationCodeEntered()
            return true
        } else if currentStr.count > inputTextLimit {
            return false
        } else {
            output.verificationCodeNotReady()
        }

        output.currentSecurityCodeChanged(with: string)
        
        return true
    }
}

extension PhoneVerificationViewController: SmartTimerProgressViewDelegate {
    func didPassedRequestedTimeInterval(_ vview: SmartTimerProgressView) {
        output.timerFinishedRunning(with: vview.isShowMessageWithDropTimer)
        vview.isShowMessageWithDropTimer = true
    }
}
