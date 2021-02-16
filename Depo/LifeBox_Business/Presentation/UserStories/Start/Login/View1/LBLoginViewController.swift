//
//  LoginViewController.swift
//  Depo
//
//  Created by Raman Harhun on 5/2/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit
import Typist
import WidgetKit

final class LBLoginViewController: ViewController {

    @IBOutlet private weak var errorViewFakeHeightConstraint: NSLayoutConstraint!

    @IBOutlet private weak var pageTitleLabel: UILabel! {
        willSet {
            newValue.textColor = UIColor(named: "loginDescriptionLabelColor")
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 18)
            newValue.text = TextConstants.loginPageMainTitle
        }
    }

    @IBOutlet private weak var loginDescriptionLabel: UILabel! {
        willSet {
            newValue.textColor = UIColor(named: "loginDescriptionLabelColor")
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 12)
            newValue.text = TextConstants.loginPageLoginButtonExplanation
        }
    }

    @IBOutlet private weak var fastLoginDescriptionLabel: UILabel! {
        willSet {
            newValue.textColor = UIColor(named: "loginDescriptionLabelColor")
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 12)
            newValue.text = TextConstants.loginPageFLButtonExplanation
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

    @IBOutlet private weak var rememberMeTitleButton: UIButton! {
        willSet {
            newValue.setTitleColor(UIColor(named: "loginDescriptionLabelColor"), for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaMedFont(size: 12)
            newValue.setTitle(TextConstants.loginPageRememberMeButtonTitle, for: .normal)
        }
    }

    @IBOutlet private weak var forgotPasswordButton: UIButton! {
        willSet {
            newValue.setTitleColor(UIColor(named: "loginDescriptionLabelColor"), for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaMedFont(size: 12)
            newValue.setTitle(TextConstants.loginPageForgetPasswordButtonTitle, for: .normal)
        }
    }
    
    @IBOutlet private weak var loginButton: UIButton! {
        willSet {
            newValue.setTitle(TextConstants.loginPageLoginButtonTitle, for: .normal)
            newValue.setTitleColor(UIColor.white, for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaDemFont(size: 14)
            newValue.backgroundColor = UIColor(named: "loginButtonBackground")
            newValue.isOpaque = true
        }
    }

    @IBOutlet private weak var loginTextField: BorderedWithInsetsTextField! {
        willSet {
            
            newValue.attributedPlaceholder = NSAttributedString(string: TextConstants.loginPageEmailFieldPlaceholder,
                                                                attributes: [NSAttributedStringKey.foregroundColor: ColorConstants.loginTextfieldPlaceholderColor])
            newValue.textColor = ColorConstants.loginTextfieldTextColor
        }
    }

    @IBOutlet private weak var passwordTextField: BorderedWithInsetsTextField! {
        willSet {
            newValue.attributedPlaceholder = NSAttributedString(string: TextConstants.loginPagePasswordFieldPlaceholder,
                                                                attributes: [NSAttributedStringKey.foregroundColor: ColorConstants.loginTextfieldPlaceholderColor])
            newValue.textColor = ColorConstants.loginTextfieldTextColor
        }
    }
    
    @IBOutlet private weak var captchaView: LoginCaptchaView! {
        willSet {
            newValue.layer.masksToBounds = true
            newValue.isHidden = true
        }
    }

    @IBOutlet private weak var errorView: ErrorBannerView! {
        willSet {
            newValue.isHidden = true
        }
    }
    
    //MARK: Vars
    var output: LoginViewOutput!
    private let keyboard = Typist.shared
    
    //MARK: - Life cycle
    override var preferredNavigationBarStyle: NavigationBarStyle {
        return .clear
    }

    override func loadView() {
        super.loadView()
        errorViewFakeHeightConstraint.isActive = false
    }

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

        prepareForDisappear()
    }
    
    //MARK: - Utility methods
    
    private func setup() {
        setupDelegates()
        configureKeyboard()
    }
    
    private func setupDelegates() {
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
    }
    
    @IBAction private func forgotPasswordButtonTapped() {
        print("forgot password")
    }

    private func prepareForDisappear() {
        ///rootViewController's navBar is hidden. But on push we shouldn't hide it
        if !output.isPresenting {
            navigationController?.setNavigationBarHidden(true, animated: true)
        }
        output.isPresenting = false
    }
    
    private func updateScroll(with keyboardFrame: CGRect) {
        let bottomInset = keyboardFrame.height + UIScreen.main.bounds.height - keyboardFrame.maxY - scrollView.safeAreaInsets.bottom
        
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
    
    @IBAction private func onRememberMeTap(_ sender: UIButton) {
        rememberMeButton.isSelected.toggle()
        
        output.rememberMe(remember: rememberMeButton.isSelected)
    }
    
    @IBAction private func onLoginTap(_ sender: Any) {
        stopEditing()
        
        if captchaView.isHidden {
            output.sendLoginAndPassword(login: loginTextField.text ?? "",
                                        password: passwordTextField.text ?? "")
        } else {
            output.sendLoginAndPasswordWithCaptcha(login: loginTextField.text ?? "",
                                                   password: passwordTextField.text ?? "",
                                                   captchaID: captchaView.currentCaptchaUUID,
                                                   captchaAnswer: captchaView.captchaAnswerTextField.text ?? "")
        }
    }
}

extension LBLoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch textField {
        case loginTextField:
            passwordTextField.becomeFirstResponder()
            
        case passwordTextField:
            if captchaView.isHidden {
                passwordTextField.resignFirstResponder()
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

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        hideErrorMessage()
        return true
    }
}

// MARK: - LoginViewInput
extension LBLoginViewController: LoginViewInput {
    
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
        showErrorMessage(with: error)
    }
    
    func passwordFieldError(_ error: String) {
        showErrorMessage(with: error)
    }
    
    func captchaFieldError(_ error: String) {
        showErrorMessage(with: error)
    }
    
    //MARK: - Alerts processing
    
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

    func failedBlockError() {
        showErrorMessage(with: TextConstants.hourBlockLoginError)
    }
}
