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
            newValue.spacing = 16
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
            newValue.isHidden = true
            newValue.errorLabel.text = TextConstants.captchaIsEmpty
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
    private let updateScrollDelay: DispatchTime = .now() + 0.3
    private var isPasswordsNotMatchError = false
    
    ///Fields (in right order)
    private let phoneEnterView: ProfilePhoneEnterView = {
        let newValue = ProfilePhoneEnterView()
        newValue.numberTextField.enablesReturnKeyAutomatically = true

        newValue.numberTextField.quickDismissPlaceholder = TextConstants.profilePhoneNumberPlaceholder
        newValue.titleLabel.text = TextConstants.registrationCellTitleGSMNumber
        
        return newValue
    }()
    
    private let emailEnterView: ProfileTextEnterView = {
        let newValue = ProfileTextEnterView()
        newValue.textField.keyboardType = .emailAddress
        newValue.textField.autocapitalizationType = .none
        newValue.textField.autocorrectionType = .no
        newValue.textField.quickDismissPlaceholder = TextConstants.enterYourEmailAddress
        newValue.textField.enablesReturnKeyAutomatically = true
        
        newValue.titleLabel.text = TextConstants.registrationCellTitleEmail
        
        return newValue
    }()
    
    private let passwordEnterView: ProfilePasswordEnterView = {
        let newValue = ProfilePasswordEnterView()
        newValue.textField.enablesReturnKeyAutomatically = true
        newValue.textField.quickDismissPlaceholder = TextConstants.enterYourNewPassword
        
        newValue.titleLabel.text = TextConstants.registrationCellTitlePassword
        
        return newValue
    }()
    
    private let rePasswordEnterView: ProfilePasswordEnterView = {
        let newValue = ProfilePasswordEnterView()
        
        newValue.textField.quickDismissPlaceholder = TextConstants.reenterYourPassword
        newValue.textField.enablesReturnKeyAutomatically = true
        
        newValue.titleLabel.text = TextConstants.registrationCellTitleReEnterPassword
        
        return newValue
    }()
    
    private let supportView: SupportBannerView = {
        let newValue = SupportBannerView()
        newValue.isHidden = true
        
        return newValue
    }()

    private let errorView: ErrorBannerView = {
        let newValue = ErrorBannerView()
        newValue.isHidden = true

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
            updateCaptcha()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if !output.isSupportFormPresenting {
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
        
        supportView.delegate = self
        
        alertsStackView.addArrangedSubview(supportView)
        alertsStackView.addArrangedSubview(errorView)

        stackView.addArrangedSubview(phoneEnterView)
        stackView.addArrangedSubview(emailEnterView)
        stackView.addArrangedSubview(passwordEnterView)
        stackView.addArrangedSubview(rePasswordEnterView)
    }
    
    private func prepareFields() {
        output.prepareCaptcha(captchaView)
        
        emailEnterView.textField.delegate = self
        passwordEnterView.textField.delegate = self
        rePasswordEnterView.textField.delegate = self
        phoneEnterView.numberTextField.delegate = self
        captchaView.captchaAnswerTextField.delegate = self
        
        phoneEnterView.responderOnNext = emailEnterView.textField
    }
    
    private func configureKeyboard() {
        keyboard
            .on(event: .willShow) { [weak self] options in
                guard let `self` = self else {
                    return
                }
                
                self.updateScroll(with: options.endFrame)
            }
            .on(event: .willHide) { [weak self] _ in
                guard let `self` = self else {
                    return
                }
                
                var inset = self.scrollView.contentInset
                inset.bottom = 0
                self.scrollView.contentInset = inset
                self.scrollView.scrollIndicatorInsets = inset
            }
            .start()
    }
    
    private func updateScroll(with keyboardFrame: CGRect) {
        var bottomInset = keyboardFrame.height + UIScreen.main.bounds.height - keyboardFrame.maxY
        
        if #available(iOS 11.0, *) {
            bottomInset -= scrollView.safeAreaInsets.bottom
        }
        
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
        self.scrollView.contentInset = insets
        self.scrollView.scrollIndicatorInsets = insets
        
        scrollToFirstResponder()
    }
    
    private func scrollToFirstResponder() {
        guard let firstResponser = self.view.firstResponder as? UIView else {
            return
        }
        
        let rectToShow: CGRect
        ///FE-1124 requerments (show nextButton if rePasswordField become first responder)
        if firstResponser == rePasswordEnterView.textField || firstResponser == captchaView.captchaAnswerTextField {
            rectToShow = self.view.convert(nextButton.frame, to: self.view)
        } else {
            rectToShow = self.view.convert(firstResponser.frame, to: self.view)
        }
        
        let rectToShowWithInset = rectToShow.offsetBy(dx: 0, dy: NumericConstants.firstResponderBottomOffset)
        self.scrollView.scrollRectToVisible(rectToShowWithInset, animated: true)
    }
    
    private func hideErrorBanner() {
        self.errorView.isHidden = true
    }
    
    private func presentCaptcha() {
        ///fix animation if appears captcha and error both
        UIView.performWithoutAnimation {
            self.captchaView.isHidden = false
        }
    }
    
    //MARK: IBActions
    @IBAction func nextActionHandler(_ sender: Any) {
        stopEditing()
        hideErrorBanner()
        output.nextButtonPressed()
    }
    
    //MARK: Actions
    @objc private func stopEditing() {
        self.view.endEditing(true)
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
            isPasswordsNotMatchError = true
            passwordEnterView.showSubtitleTextAnimated(text: TextConstants.registrationPasswordNotMatchError)
        case .phoneIsEmpty:
            phoneEnterView.showTextAnimated(text: TextConstants.registrationCellPlaceholderPhone)
        case .captchaIsEmpty:
            captchaView.showErrorAnimated()
        }
    }
    
    func showErrorTitle(withText: String) {
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.errorView.message = withText
            self.errorView.isHidden = false
            
            self.view.layoutIfNeeded()
        }
        
        let errorRect = self.view.convert(errorView.frame, to: self.view)
        scrollView.scrollRectToVisible(errorRect, animated: true)
    }
    
    func setupCaptcha() {
        presentCaptcha()
    }
    
    func showSupportView() {
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.supportView.isHidden = false
            
            self.view.layoutIfNeeded()
        }
        
        let supportRect = self.view.convert(supportView.frame, to: self.view)
        scrollView.scrollRectToVisible(supportRect, animated: true)
    }
}

extension RegistrationViewController: RegistrationViewDelegate {
    
    func show(errorString: String) {
        DispatchQueue.toMain {
            self.showErrorTitle(withText: errorString)
        }
    }
    
    func showCaptcha() {
        presentCaptcha()
    }
    
    func updateCaptcha() {
        captchaView.updateCaptcha()
    }
}

extension RegistrationViewController: UITextFieldDelegate {
    var showPlaceholderColor: UIColor {
        return .yellow
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch textField {
        case phoneEnterView.numberTextField:
            phoneEnterView.responderOnNext?.becomeFirstResponder()
            
        case emailEnterView.textField:
            passwordEnterView.textField.becomeFirstResponder()
            
        case passwordEnterView.textField:
            rePasswordEnterView.textField.becomeFirstResponder()
            
        case rePasswordEnterView.textField:
            if captchaView.isHidden {
                rePasswordEnterView.textField.resignFirstResponder()
            } else {
                captchaView.captchaAnswerTextField.becomeFirstResponder()
            }
            
        case captchaView.captchaAnswerTextField:
            captchaView.captchaAnswerTextField.resignFirstResponder()
            
        default:
            assertionFailure()
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
            if isPasswordsNotMatchError {
                passwordEnterView.hideSubtitleAnimated()
                isPasswordsNotMatchError = false
            }
            rePasswordEnterView.hideSubtitleAnimated()
        case captchaView.captchaAnswerTextField:
            captchaView.hideErrorAnimated()
            
            ///need to scroll to nextButton(in some cases typist not worked)
            DispatchQueue.main.asyncAfter(deadline: updateScrollDelay) {
                self.scrollToFirstResponder()
            }
        default:
            assertionFailure()
        }
    }
}

// MARK: - SupportBannerViewDelegate
extension RegistrationViewController: SupportBannerViewDelegate {
    func openSupport() {
        output.openSupport()
    }
}
