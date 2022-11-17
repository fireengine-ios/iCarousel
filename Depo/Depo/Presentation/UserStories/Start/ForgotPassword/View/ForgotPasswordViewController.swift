//
//  ForgotPasswordForgotPasswordViewController.swift
//  Depo
//
//  Created by Oleg on 15/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit
import Typist

final class ForgotPasswordViewController: ViewController {

    var output: ForgotPasswordViewOutput!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var infoTitle: UILabel!
   
    @IBOutlet weak var loginEnterView: ProfileTextEnterView!

    @IBOutlet private weak var captchaView: CaptchaView!
    
    @IBOutlet weak var sendPasswordButton: WhiteButtonWithRoundedCorner!

    fileprivate let keyboard = Typist.shared

    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !Device.isIpad {
            setTitle(withString: localized(.resetPasswordTitle))
        }
        
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))

        setupViews()
        output.viewIsReady()
        configureKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loginEnterView.textField.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if isMovingFromParent {
            output.userNavigatedBack()
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        endEditing()
    }
    
    func endEditing() {
        view.endEditing(true)
    }

    func setupViews() {
        setupInfoTitle()
        setupInputTitle()
        setupInputField()
        setupButton()
        setupCaptchaView()
    }

    private func setupInfoTitle() {
        infoTitle.textColor = AppColor.forgetPassText.color
        if Device.isIpad {
            infoTitle.font = .appFont(.medium, size: 20)
            infoTitle.textAlignment = .center
        } else {
            infoTitle.font = .appFont(.medium, size: 15)
            infoTitle.textAlignment = .left
        }
    }
    
    private func setupInputTitle() {
        let titleLabel = loginEnterView.titleLabel
        loginEnterView.textField.text = ""
        titleLabel.textColor = AppColor.forgetPassText.color

        if Device.isIpad {
            titleLabel.font = .appFont(.light, size: 20)
            titleLabel.textAlignment = .center
        } else {
            titleLabel.font = .appFont(.light, size: 15)
            titleLabel.textAlignment = .left
        }
    }
    
    private func setupInputField() {
        let textField = loginEnterView.textField

        var font: UIFont = .appFont(.light, size: 15)
        
        if Device.isIpad {
            font = .appFont(.light, size: 20)
        }

        textField.textColor = AppColor.forgetPassText.color
        textField.font = font
        textField.enablesReturnKeyAutomatically = true
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.keyboardType = .emailAddress
        textField.textContentType = .emailAddress

        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    private func setupButton() {
        sendPasswordButton.setTitle(localized(.resetPasswordButtonTitle), for: .normal)
        sendPasswordButton.setTitleColor(.white, for: .normal)
        sendPasswordButton.titleLabel?.font = .appFont(.medium, size: 16)
        sendPasswordButton.setBackgroundColor(AppColor.forgetPassButtonDisable.color, for: .disabled)
        sendPasswordButton.setBackgroundColor(AppColor.forgetPassButtonNormal.color, for: .normal)

        updateButtonState()
    }
    
    private func setupCaptchaView() {
        captchaView.captchaAnswerTextField.placeholder = localized(.resetPasswordCaptchaPlaceholder)
        captchaView.captchaAnswerTextField.delegate = self
        captchaView.captchaAnswerTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc private func textFieldDidChange() {
        updateButtonState()
    }
    
    private func updateButtonState() {
        guard !(loginEnterView.textField.text?.isEmpty ?? true),
              !(captchaView.captchaAnswerTextField.text?.isEmpty ?? true) else {
                sendPasswordButton.isEnabled = false
                return
        }
        sendPasswordButton.isEnabled = true
    }

    deinit {
        keyboard.stop()
    }
    
    fileprivate func configureKeyboard() {
        
        keyboard.on(event: .willChangeFrame) { [weak self] options in
            guard let `self` = self else {
                return
            }
            self.updateContentInsetWithKeyboardFrame(options.endFrame)
            self.scrollToFirstResponderIfNeeded(animated: false)
            }
            .on(event: .willShow) { [weak self] options in
                guard let `self` = self else {
                    return
                }
                self.updateContentInsetWithKeyboardFrame(options.endFrame)
                self.scrollToFirstResponderIfNeeded(animated: false)
            }
            .on(event: .willHide) { [weak self] _ in
                guard let `self` = self else {
                    return
                }
                var inset = self.scrollView.contentInset
                inset.bottom = 0

                self.scrollView.contentInset = inset
                self.scrollView.setContentOffset(.zero, animated: true)
            }
            .start()
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
        view.layoutIfNeeded()
    }

    private func updateContentInsetWithKeyboardFrame(_ keyboardFrame: CGRect) {
        let bottomInset = keyboardFrame.height + UIScreen.main.bounds.height - keyboardFrame.maxY
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
        scrollView.contentInset = insets
        scrollView.scrollIndicatorInsets = insets
    }

    private func scrollToFirstResponderIfNeeded(animated: Bool) {
        guard let firstResponser = view.firstResponder as? UIView else {
            return
        }

        let frameOnWindow = firstResponser.frameOnWindow
        let frameOnWindowWithInset = frameOnWindow.offsetBy(dx: 0.0, dy: 50.0)
        scrollView.scrollRectToVisible(frameOnWindowWithInset, animated: animated)
    }

    // MARK: Buttons actions 
    
    @IBAction func onSendPasswordButton() {
        endEditing()

        let login = loginEnterView.textField.text ?? ""
        let captchaUdid = captchaView.currentCaptchaUUID
        let captchaEntered = captchaView.captchaAnswerTextField.text ?? ""

        output.resetPassword(withLogin: login, enteredCaptcha: captchaEntered, captchaUDID: captchaUdid)
    }
}

// MARK: - UITextFieldDelegate

extension ForgotPasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if loginEnterView.textField == textField {
            captchaView.captchaAnswerTextField.becomeFirstResponder()
            scrollToFirstResponderIfNeeded(animated: true)
        } else {
            onSendPasswordButton()
        }
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch textField {
        case loginEnterView.textField:
            if string == " " {
                return false
            } else if textField.text?.count == 0 {
                if string == "+" {
                    output.startedEnteringPhoneNumber(withPlus: true)
                    return false
                } else if string.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil {
                    /// Later on, according to condition, we may add this statement again!
                    //output.startedEnteringPhoneNumber(withPlus: false)
                }
            }

        case captchaView.captchaAnswerTextField:
            break

        default:
            assertionFailure()
        }

        return true
    }
}

// MARK: - ForgotPasswordViewInput

extension ForgotPasswordViewController: ForgotPasswordViewInput {
    func setupInitialState() {

    }

    func showCapcha() {
        captchaView.updateCaptcha()
        updateButtonState()
    }

    func setTexts(_ texts: ForgotPasswordTexts) {
        infoTitle.text = texts.instructions
        loginEnterView.titleLabel.text = texts.emailInputTitle

        let font = loginEnterView.textField.font ?? UIFont()
        loginEnterView.textField.attributedPlaceholder = NSAttributedString(
            string: texts.emailPlaceholder,
            attributes: [.foregroundColor: ColorConstants.textDisabled, .font: font]
        )
    }

    func enterPhoneCountryCode(countryCode: String) {
        var loginText = ""

        if let text = loginEnterView.textField.text {
            loginText = text
        }

        loginText = loginText + countryCode
        loginEnterView.textField.text = loginText
    }

    func insertPhoneCountryCode(countryCode: String) {
        var loginText = countryCode

        if let text = loginEnterView.textField.text {
            loginText = loginText + text
        }

        loginEnterView.textField.text = loginText
    }
}
