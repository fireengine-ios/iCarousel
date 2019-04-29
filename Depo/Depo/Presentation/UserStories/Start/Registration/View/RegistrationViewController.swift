//
//  RegistrationViewController.swift
//  Depo_LifeTech
//
//  Created by Raman Harhun on 4/23/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit
import Typist

protocol RegistrationViewDelegate: class {
    func show(errorString: String)
    func showCaptcha()
}

final class RegistrationViewController: ViewController {
    
    //MARK: IBOutlets
    @IBOutlet weak var shadowView: UIView! {
        willSet {
            newValue.isHidden = true
        }
    }
    
    @IBOutlet weak var nextButton: RoundedInsetsButton! {
        willSet {
            newValue.setTitle(TextConstants.registrationNextButtonText, for: .normal)
            newValue.setTitleColor(UIColor.white, for: .normal)
            newValue.backgroundColor = UIColor.lrTealish
            newValue.isOpaque = true
        }
    }
    
    @IBOutlet weak var alertsStackView: UIStackView! {
        willSet {
            newValue.spacing = 0
            newValue.alignment = .fill
            newValue.axis = .vertical
            newValue.distribution = .fill
        }
    }
    
    @IBOutlet weak var stackView: UIStackView! {
        willSet {
            newValue.spacing = 16
            newValue.alignment = .fill
            newValue.axis = .vertical
            newValue.distribution = .fill
        }
    }
    
    @IBOutlet weak var captchaView: CaptchaView! {
        willSet {
            ///need to hide content
            newValue.layer.masksToBounds = true
            newValue.errorLabel.text = TextConstants.loginScreenInvalidCaptchaError
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView! {
        willSet {
            let dismissKeyboardGuesture = UITapGestureRecognizer(target: self,
                                                                 action: #selector(stopEditing))
            newValue.addGestureRecognizer(dismissKeyboardGuesture)
            newValue.delaysContentTouches = false
        }
    }
    
    //MARK: Vars
    private let keyboard = Typist.shared
    var output: RegistrationViewOutput!
    
    ///Fields (in right order)
    private let phoneEnterView: ProfilePhoneEnterView = {
        let newValue = ProfilePhoneEnterView()
        newValue.numberTextField.enablesReturnKeyAutomatically = true
        
        newValue.titleLabel.text = TextConstants.registrationCellTitleGSMNumber
        
        return newValue
    }()
    
    private let emailEnterView: ProfileTextEnterView = {
        let newValue = ProfileTextEnterView()
        newValue.textField.keyboardType = .emailAddress
        newValue.textField.autocapitalizationType = .none
        newValue.textField.autocorrectionType = .no
        newValue.textField.placeholder = TextConstants.enterYourEmailAddress
        newValue.textField.enablesReturnKeyAutomatically = true
        
        newValue.titleLabel.text = TextConstants.registrationCellTitleEmail
        
        return newValue
    }()
    
    private let passwordEnterView: ProfilePasswordEnterView = {
        let newValue = ProfilePasswordEnterView()
        newValue.textField.placeholder = TextConstants.enterYourNewPassword
        newValue.textField.enablesReturnKeyAutomatically = true
        
        newValue.titleLabel.text = TextConstants.registrationCellTitlePassword
        
        return newValue
    }()
    
    private let rePasswordEnterView: ProfilePasswordEnterView = {
        let newValue = ProfilePasswordEnterView()
        newValue.textField.placeholder = TextConstants.reenterYourPassword
        newValue.textField.enablesReturnKeyAutomatically = true
        
        newValue.titleLabel.text = TextConstants.registrationCellTitleReEnterPassword
        
        return newValue
    }()
    
    //MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        output.viewIsReady()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavBar()

        if !captchaView.isHidden {
            captchaView.updateCaptcha()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if !output.isSupportFormPresenting {
//            hidenNavigationBarStyle()
            navigationController?.setNavigationBarHidden(true, animated: true)
        }
        output.isSupportFormPresenting = false

    }
    
    override var preferredNavigationBarStyle: NavigationBarStyle {
        return .clear
    }
    
    //MARK: Utility Methods (private)
    private func setup() {
        setupStackView()
        configureKeyboard()
    }
    
    private func setupNavBar() {
        navigationBarWithGradientStyle()
        backButtonForNavigationItem(title: TextConstants.backTitle)
        setNavigationTitle(title: TextConstants.registerTitle)
    }
    
    private func setupStackView() {
        prepareFields()
        
        stackView.addArrangedSubview(phoneEnterView)
        stackView.addArrangedSubview(emailEnterView)
        stackView.addArrangedSubview(passwordEnterView)
        stackView.addArrangedSubview(rePasswordEnterView)
    }
    
    private func prepareFields() {
        phoneEnterView.responderOnNext = emailEnterView.textField
        emailEnterView.responderOnNext = passwordEnterView.textField
        passwordEnterView.responderOnNext = rePasswordEnterView.textField
        rePasswordEnterView.responderOnNext = captchaView.captchaAnswerTextField
        
        emailEnterView.textField.delegate = self
        passwordEnterView.textField.delegate = self
        rePasswordEnterView.textField.delegate = self
        phoneEnterView.numberTextField.delegate = self
        captchaView.captchaAnswerTextField.delegate = self
    }
    
    private func configureKeyboard() {
        keyboard
            .on(event: .willShow) { [weak self] options in
                guard let `self` = self else {
                    return
                }
                
                let keyboardFrame = options.endFrame
                let bottomInset = keyboardFrame.height + UIScreen.main.bounds.height - keyboardFrame.maxY
                let insets = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
                self.scrollView.contentInset = insets
                self.scrollView.scrollIndicatorInsets = insets
                
                guard let firstResponser = self.view.firstResponder as? UIView else {
                    return
                }
                
                let rectToShow = self.view.convert(firstResponser.frame, to: self.view)
                let rectToShowWithInset = rectToShow.offsetBy(dx: 0, dy: NumericConstants.firstResponderBottomOffset)
                self.scrollView.scrollRectToVisible(rectToShowWithInset, animated: true)
            }
            .on(event: .willHide) { [weak self] _ in
                guard let `self` = self else {
                    return
                }
                
                var inset = self.scrollView.contentInset
                inset.bottom = 0
                self.scrollView.contentInset = inset
                self.scrollView.scrollIndicatorInsets = inset
                
                self.scrollView.setContentOffset(.zero, animated: true)
            }
            .start()
    }
    
    private func removeErrorBanner() {
        alertsStackView.arrangedSubviews.forEach {
            if $0 is SignUpErrorView {
                alertsStackView.removeArrangedSubview($0)
                $0.removeFromSuperview()
            }
        }
    }
    
    private func updateCaptcha() {
        captchaView.updateCaptcha()
    }
    
    private func presentCaptcha() {
        UIView.animate(withDuration: NumericConstants.animationDuration) { [weak self] in
            self?.captchaView.isHidden = false
            
            self?.view.layoutIfNeeded()
        }
    }
    
    //MARK: IBActions
    @IBAction func nextActionHandler(_ sender: Any) {
        stopEditing()
        removeErrorBanner()
        output.nextButtonPressed()
    }
    
    //MARK: Actions
    @objc private func stopEditing() {
        self.view.firstResponder?.resignFirstResponder()
    }
}

extension RegistrationViewController: RegistrationViewInput {
    func collectInputedUserInfo() {
        output.collectedUserInfo(email: emailEnterView.textField.text ?? "",
                                 code: phoneEnterView.codeTextField.text ?? "",
                                 phone: phoneEnterView.numberTextField.text ?? "",
                                 password: passwordEnterView.textField.text ?? "",
                                 repassword: rePasswordEnterView.textField.text ?? "",
                                 captchaID: captchaView.currentCaptchaUUID,
                                 captchaAnswer: captchaView.captchaAnswerTextField.text ?? "")
    }
    
    func showInfoButton(forType type: UserValidationResults) {
        switch type {
        case .mailNotValid:
            emailEnterView.showSubtitleTextAnimated(text: TextConstants.registrationMailError)
        case .mailIsEmpty:
            emailEnterView.showSubtitleTextAnimated(text: TextConstants.registrationCellPlaceholderEmail)
        case .passwordIsEmpty:
            passwordEnterView.showSubtitleTextAnimated(text: TextConstants.registrationCellPlaceholderPassword)
        case .passwordNotValid:
            passwordEnterView.showSubtitleTextAnimated(text: TextConstants.registrationPasswordError)
        case .repasswordIsEmpty:
            rePasswordEnterView.showSubtitleTextAnimated(text: TextConstants.registrationCellPlaceholderReFillPassword)
        case .passwodsNotMatch:
            passwordEnterView.showSubtitleTextAnimated(text: TextConstants.registrationPasswordNotMatchError)
        case .phoneIsEmpty:
            phoneEnterView.showTextAnimated(text: TextConstants.registrationCellPlaceholderPhone)
        case .captchaIsEmpty:
            captchaView.showErrorAnimated()
        }
    }
    
    func showErrorTitle(withText: String) {
        let errorView = SignUpErrorView(errorMessage: withText)
        alertsStackView.addArrangedSubview(errorView)
        
        let errorRect = self.view.convert(errorView.frame, to: self.view)
        scrollView.scrollRectToVisible( errorRect, animated: true)
    }
    
    func setupCaptcha() {
        presentCaptcha()
    }
    
    func showSupportView(_ view: SignUpSupportView) {
        if !alertsStackView.arrangedSubviews.contains(where: { $0 is SignUpSupportView }) {
            alertsStackView.insertArrangedSubview(view, at: 0)
        }
        
        let supportViewRect = self.view.convert(view.frame, to: self.view)
        scrollView.scrollRectToVisible( supportViewRect, animated: true)
    }
}

extension RegistrationViewController: RegistrationViewDelegate {
    
    func show(errorString: String) {
        showErrorTitle(withText: errorString)
    }
    
    func showCaptcha() {
        presentCaptcha()
    }
}

extension RegistrationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch textField {
        case emailEnterView.textField:
            emailEnterView.responderOnNext?.becomeFirstResponder()
        case phoneEnterView.numberTextField:
            phoneEnterView.responderOnNext?.becomeFirstResponder()
        case passwordEnterView.textField:
            passwordEnterView.responderOnNext?.becomeFirstResponder()
        case rePasswordEnterView.textField:
            if captchaView.isHidden {
                rePasswordEnterView.textField.resignFirstResponder()
            } else {
                rePasswordEnterView.responderOnNext?.becomeFirstResponder()
            }
        case captchaView.captchaAnswerTextField:
            captchaView.captchaAnswerTextField.resignFirstResponder()
        default:
            break
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case phoneEnterView.numberTextField:
            phoneEnterView.hideSubtitleAnimated()
        case emailEnterView.textField:
            emailEnterView.hideSubtitleAnimated()
        case passwordEnterView.textField:
            passwordEnterView.hideSubtitleAnimated()
        case rePasswordEnterView.textField:
            rePasswordEnterView.hideSubtitleAnimated()
        case captchaView.captchaAnswerTextField:
            captchaView.hideErrorAnimated()
        default:
            break
        }
        
        if textField != phoneEnterView.codeTextField {
            textField.text = ""
        }
    }
}
