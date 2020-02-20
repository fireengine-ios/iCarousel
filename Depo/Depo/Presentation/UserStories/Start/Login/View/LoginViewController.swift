//
//  LoginViewController.swift
//  Depo
//
//  Created by Raman Harhun on 5/2/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit
import Typist

final class LoginViewController: ViewController {

    //MARK: IBOutlets
    @IBOutlet private weak var alertsStackView: UIStackView! {
        willSet {
            newValue.spacing = 16
            newValue.alignment = .fill
            newValue.axis = .vertical
            newValue.distribution = .fill
        }
    }
    
    @IBOutlet private weak var fieldsStackView: UIStackView! {
        willSet {
            newValue.spacing = 16
            newValue.alignment = .fill
            newValue.axis = .vertical
            newValue.distribution = .fill
        }
    }

    @IBOutlet private weak var rememberMeLabel: UILabel! {
        willSet {
            newValue.textColor = .black
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 15)
            newValue.text = TextConstants.loginRememberMyCredential
        }
    }
    
    @IBOutlet private weak var scrollView: UIScrollView! {
        willSet {
            let dismissKeyboardGuesture = UITapGestureRecognizer(target: self,
                                                                 action: #selector(stopEditing))
            newValue.addGestureRecognizer(dismissKeyboardGuesture)
            newValue.delaysContentTouches = false
        }
    }
    
    @IBOutlet private weak var rememberMeButton: UIButton! {
        willSet {
            let normalImage = UIImage(named: "checkBoxNotSelected")
            newValue.setImage(normalImage, for: .normal)
            
            let selectedImage = UIImage(named: "checkbox_active")
            newValue.setImage(selectedImage, for: .selected)
        }
    }
    
    @IBOutlet private weak var loginButton: RoundedInsetsButton! {
        willSet {
            newValue.setTitle(TextConstants.loginTitle, for: .normal)
            newValue.setTitleColor(UIColor.white, for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaDemFont(size: 18)
            newValue.backgroundColor = UIColor.lrTealish
            newValue.isOpaque = true
        }
    }
    
    @IBOutlet private weak var forgotPasswordButton: UIButton! {
        willSet {
            let attributes: [NSAttributedStringKey : Any] = [
                .foregroundColor : UIColor.lrTealish,
                .underlineStyle : NSUnderlineStyle.styleSingle.rawValue,
                .font : UIFont.TurkcellSaturaDemFont(size: 16)
            ]
            
            let attributedTitle = NSAttributedString(string: TextConstants.loginCantLoginButtonTitle,
                                                     attributes: attributes)
            newValue.setAttributedTitle(attributedTitle, for: .normal)
            newValue.isOpaque = true
        }
    }
    
    @IBOutlet private weak var loginEnterView: ProfileTextEnterView! {
        willSet {
            newValue.textField.enablesReturnKeyAutomatically = true
            newValue.textField.autocapitalizationType = .none
            newValue.textField.autocorrectionType = .no
            newValue.textField.quickDismissPlaceholder = TextConstants.loginEmailOrPhonePlaceholder
            newValue.titleLabel.text = TextConstants.loginCellTitleEmail
        }
    }
    
    @IBOutlet private weak var passwordEnterView: ProfilePasswordEnterView! {
        willSet {
            newValue.textField.enablesReturnKeyAutomatically = true

            newValue.textField.quickDismissPlaceholder = TextConstants.loginPasswordPlaceholder

            newValue.titleLabel.text = TextConstants.loginCellTitlePassword
        }
    }
    
    @IBOutlet private weak var captchaView: CaptchaView! {
        willSet {
            ///need to hide content
            newValue.layer.masksToBounds = true
            newValue.isHidden = true
        }
    }

    @IBOutlet private weak var errorView: ErrorBannerView! {
        willSet {
            newValue.isHidden = true
        }
    }
    
    @IBOutlet private weak var bannerView: SupportFormBannerView! {
        willSet {
            newValue.isHidden = true
            newValue.delegate = self
            newValue.screenType = .login
        }
    }
    
    //MARK: Vars
    var output: LoginViewOutput!
    private let keyboard = Typist.shared
    
    //MARK: - Life cycle
    override var preferredNavigationBarStyle: NavigationBarStyle {
        return .clear
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        
        output.viewIsReady()
        
        #if DEBUG
        loginEnterView.textField.text = "mavokij291@4tmail.com"//"qwerty@my.com"// "test3@test.test"//"test2@test.test"//"testasdasdMail@notRealMail.yep"

        passwordEnterView.textField.text = "qwerty"// "zxcvbn"//".FsddQ646"
        #endif
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
        
        prepareForDisappear()
    }
    
    //MARK: - Utility methods
    
    private func setup() {
        setupDelegates()
        configureKeyboard()
    }
    
    private func setupDelegates() {
        output.prepareCaptcha(captchaView)
        
        loginEnterView.textField.delegate = self
        passwordEnterView.textField.delegate = self
        captchaView.captchaAnswerTextField.delegate = self
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
    
    private func setupNavBar() {
        navigationBarWithGradientStyle()
        
        setNavigationTitle(title: TextConstants.loginTitle)
        backButtonForNavigationItem(title: TextConstants.backTitle)
        setNavigationRightBarButton(title: TextConstants.loginFAQButton, target: self, action: #selector(handleFaqButtonTap))
    }
    
    @objc private func handleFaqButtonTap() {
        output.openFaqSupport()
    }

    private func prepareForDisappear() {
        ///rootViewController's navBar is hidden. But on push we shouldn't hide it
        if !output.isPresenting {
            navigationController?.setNavigationBarHidden(true, animated: true)
        }
        output.isPresenting = false
    }
    
    private func updateScroll(with keyboardFrame: CGRect) {
        var bottomInset = keyboardFrame.height + UIScreen.main.bounds.height - keyboardFrame.maxY
        
        if #available(iOS 11.0, *) {
            bottomInset -= scrollView.safeAreaInsets.bottom
        }
        
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
    
    @objc private func stopEditing() {
        view.endEditing(true)
    }
    
    //MARK: - IBActions
    
    @IBAction func onRememberMeTap(_ sender: UIButton) {
        sender.isSelected.toggle()
        
        output.rememberMe(remember: sender.isSelected)
    }
    
    @IBAction func onLoginTap(_ sender: Any) {
        stopEditing()
        
        if captchaView.isHidden {
            output.sendLoginAndPassword(login: loginEnterView.textField.text ?? "",
                                        password: passwordEnterView.textField.text ?? "")
        } else {
            output.sendLoginAndPasswordWithCaptcha(login: loginEnterView.textField.text ?? "",
                                                   password: passwordEnterView.textField.text ?? "",
                                                   captchaID: captchaView.currentCaptchaUUID,
                                                   captchaAnswer: captchaView.captchaAnswerTextField.text ?? "")
        }
    }
    
    @IBAction func onForgotPasswordTap(_ sender: Any) {
        output.onForgotPasswordTap()
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch textField {
        case loginEnterView.textField:
            passwordEnterView.textField.becomeFirstResponder()
            
        case passwordEnterView.textField:
            if captchaView.isHidden {
                passwordEnterView.textField.resignFirstResponder()
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
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        switch textField {
        case loginEnterView.textField:
            loginEnterView.hideSubtitleAnimated()
            
        case passwordEnterView.textField:
            passwordEnterView.hideSubtitleAnimated()
            
        case captchaView.captchaAnswerTextField:
            captchaView.hideErrorAnimated()
            
        default:
            assertionFailure()
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
                    output.startedEnteringPhoneNumber(withPlus: false)
                }
            }
            
        case passwordEnterView.textField, captchaView.captchaAnswerTextField:
            break
            
        default:
            assertionFailure()
        }
        
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        switch textField {
        case loginEnterView.textField:
            
            let countryCodeWithZero = "+(90)0"
            if var text = textField.text, text.starts(with: countryCodeWithZero) {
                text.remove(at: text[countryCodeWithZero.count - 1])
                textField.text = text
            }
        case passwordEnterView.textField, captchaView.captchaAnswerTextField:
            break
            
        default:
            assertionFailure()
        }
        
        return true
    }
}

// MARK: - LoginViewInput
extension LoginViewController: LoginViewInput {
    
    //MARK: Captcha field processing
    func showCaptcha() {
        ///fix animation if appears captcha and error both
        UIView.performWithoutAnimation {
            self.captchaView.isHidden = false
        }
    }
    
    func refreshCaptcha() {
        captchaView.updateCaptcha()
    }
    
    //MARK: Fields alerts processing
    func loginFieldError(_ error: String) {
        loginEnterView.showSubtitleTextAnimated(text: error)
    }
    
    func passwordFieldError(_ error: String) {
        passwordEnterView.showSubtitleTextAnimated(text: error)
    }
    
    func captchaFieldError(_ error: String) {
        captchaView.showErrorAnimated(text: error)
    }
    
    func dehighlightTitles() {
        loginEnterView.hideSubtitleAnimated()
        passwordEnterView.hideSubtitleAnimated()
        captchaView.hideErrorAnimated()
    }
    
    //MARK: - Alerts processing
    
    func showSupportView() {
        bannerView.type = .support
    }
    
    func showFAQView() {
        bannerView.type = .faq
        
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.bannerView.isHidden = false
        }
    }
    
    func showErrorMessage(with text: String) {
        errorView.message = text
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.errorView.isHidden = false
            
            self.view.layoutIfNeeded()
        }
        
        let errorViewRect = view.convert(errorView.frame, to: view)
        scrollView.scrollRectToVisible(errorViewRect, animated: true)        
    }
    
    func hideErrorMessage() {
        errorView.isHidden = true
    }
    
    //MARK: login textField processing
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
    
    //MARK: block user processing
    func failedBlockError() {
        showErrorMessage(with: TextConstants.hourBlockLoginError)
    }
}

extension LoginViewController: SupportFormBannerViewDelegate {
   func supportFormBannerViewDidClick(_ bannerView: SupportFormBannerView) {
        if bannerView.type == .support {
            output?.openSupport()
        } else {
            bannerView.shouldShowPicker = true
            bannerView.becomeFirstResponder()
        }
    }
    
    func supportFormBannerView(_ bannerView: SupportFormBannerView, didSelect type: SupportFormSubjectTypeProtocol) {
        output.openSubjectDetails(type: type)
    }
  
    func supportFormBannerViewDidCancel(_ bannerView: SupportFormBannerView) {
        bannerView.resignFirstResponder()
        scrollView.setContentOffset(.zero, animated: true)
    }
}
