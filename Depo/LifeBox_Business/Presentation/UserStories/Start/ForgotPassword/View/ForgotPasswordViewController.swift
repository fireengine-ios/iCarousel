//
//  ForgotPasswordForgotPasswordViewController.swift
//  Depo
//
//  Created by Oleg on 15/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit
import Typist

class ForgotPasswordViewController: ViewController, ForgotPasswordViewInput {

    var output: ForgotPasswordViewOutput!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var infoTitle: UILabel!
   
    @IBOutlet weak var emailTitle: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet private weak var captchaView: CaptchaView!
    
    @IBOutlet weak var sendPasswordButton: WhiteButtonWithRoundedCorner!

    fileprivate let keyboard = Typist.shared

    // MARK: Life cycle
    override var preferredNavigationBarStyle: NavigationBarStyle {
        return .clear
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !Device.isIpad {
            setTitle(withString: TextConstants.resetPasswordTitle)
        }
        
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        output.viewIsReady()
        configureKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarWithGradientStyle()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        emailTextField.becomeFirstResponder()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        endEditing()
    }
    
    func endEditing() {
        view.endEditing(true)
    }
    
    func setupVisableSubTitle() {
        updateSubTitleForTurkcell()
    }
    
    func setupVisableTexts() {
        setupInfoTitle()
        setupSubTitle()
        setupEmailTitle()
        setupEmailField()
        setupButton()
        setupCaptchaView()
    }
    
    private func setupSubTitle() {
        subTitle.text = TextConstants.resetPasswordSubTitle
        
        subTitle.textColor = ColorConstants.removeConnection
        
        if Device.isIpad {
            subTitle.font = UIFont.TurkcellSaturaRegFont(size: 24)
            subTitle.textAlignment = .center
        } else {
            subTitle.font = UIFont.TurkcellSaturaRegFont(size: 18)
            subTitle.textAlignment = .left
        }
    }
    
    private func updateSubTitleForTurkcell() {        
        subTitle.text = TextConstants.forgotPasswordSubTitle
    }
    
    private func setupInfoTitle() {
        
        infoTitle.text = TextConstants.resetPasswordInfo
        
        infoTitle.textColor = UIColor.black
        if Device.isIpad {
            infoTitle.font = UIFont.TurkcellSaturaBolFont(size: 20)
            infoTitle.textAlignment = .center
        } else {
            infoTitle.font = UIFont.TurkcellSaturaBolFont(size: 15)
            infoTitle.textAlignment = .left
        }
    }
    
    private func setupEmailTitle() {
        
        emailTitle.text = TextConstants.resetPasswordEmailTitle
        
        emailTitle.textColor = UIColor.lrTealishTwo
        if Device.isIpad {
            emailTitle.font = UIFont.TurkcellSaturaDemFont(size: 24)
            emailTitle.textAlignment = .center
        } else {
            emailTitle.font = UIFont.TurkcellSaturaDemFont(size: 18)
            emailTitle.textAlignment = .left
        }
    }
    
    private func setupEmailField() {
        
        var font = UIFont.TurkcellSaturaRegFont(size: 18)
        
        if Device.isIpad {
            font = UIFont.TurkcellSaturaRegFont(size: 24)
        }
        
        emailTextField.attributedPlaceholder = NSAttributedString(string: TextConstants.resetPasswordEmailPlaceholder,
                                                               attributes: [NSAttributedString.Key.foregroundColor: ColorConstants.textDisabled,
                                                                            NSAttributedString.Key.font: font])
        
        emailTextField.textColor = UIColor.black
        emailTextField.font = font
        emailTextField.delegate = self
        emailTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    private func setupButton() {
        sendPasswordButton.setTitle(TextConstants.resetPasswordSendPassword, for: UIControlState.normal)
        sendPasswordButton.setTitleColor(ColorConstants.whiteColor, for: UIControlState.normal)
        sendPasswordButton.titleLabel?.font = UIFont.TurkcellSaturaDemFont(size: 18)
        sendPasswordButton.setBackgroundColor(UIColor.lrTealishTwo.withAlphaComponent(0.5), for: .disabled)
        sendPasswordButton.setBackgroundColor(UIColor.lrTealishTwo, for: .normal)

        updateButtonState()
    }
    
    private func setupCaptchaView() {
        captchaView.captchaAnswerTextField.placeholder = TextConstants.resetPasswordCaptchaPlaceholder
        captchaView.captchaAnswerTextField.delegate = self
        captchaView.captchaAnswerTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc private func textFieldDidChange() {
        updateButtonState()
    }
    
    private func updateButtonState() {
        guard !(emailTextField.text?.isEmpty ?? true),
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

    // MARK: IN
    func setupInitialState() {
        
    }
    
    func showCapcha() {
        captchaView.updateCaptcha()
        updateButtonState()
    }
    
    // MARK: Buttons actions 
    
    @IBAction func onSendPasswordButton() {
        endEditing()
        
        let captchaUdid = captchaView.currentCaptchaUUID
        let captchaEntered = captchaView.captchaAnswerTextField.text
        
        output.onSendPassword(withEmail: emailTextField.text ?? "", enteredCaptcha: captchaEntered ?? "", captchaUDID: captchaUdid)
    }
}

// MARK: UITextFieldDelegate

extension ForgotPasswordViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if emailTextField == textField {
            captchaView.captchaAnswerTextField.becomeFirstResponder()
            scrollToFirstResponderIfNeeded(animated: true)
        } else {
            onSendPasswordButton()
        }
        return true
    }
}
