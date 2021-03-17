//
//  LoginViewController.swift
//  Depo
//
//  Created by Raman Harhun on 5/2/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit
import Typist
import DigitalGate

final class LoginViewController: ViewController {

    @IBOutlet private weak var errorViewFakeHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var loginButtonToCaptchaStackViewTopConstraint: NSLayoutConstraint!

    @IBOutlet private weak var pageTitleLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.loginDescriptionLabel
            newValue.font = UIFont.GTAmericaStandardRegularFont(size: 18)
            newValue.text = TextConstants.loginPageMainTitle
        }
    }

    @IBOutlet private weak var loginDescriptionLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.loginDescriptionLabel
            newValue.font = UIFont.GTAmericaStandardRegularFont(size: 12)
            newValue.text = TextConstants.loginPageLoginButtonExplanation
        }
    }

    @IBOutlet private weak var fastLoginDescriptionLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.loginDescriptionLabel
            newValue.font = UIFont.GTAmericaStandardRegularFont(size: 12)
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
            
            let selectedImage = UIImage(named: "checkboxSelected")
            newValue.setImage(selectedImage, for: .selected)
        }
    }

    @IBOutlet private weak var rememberMeTitleButton: UIButton! {
        willSet {
            newValue.setTitleColor(ColorConstants.loginDescriptionLabel, for: .normal)
            newValue.titleLabel?.font = UIFont.GTAmericaStandardRegularFont(size: 12)
            newValue.setTitle(TextConstants.loginPageRememberMeButtonTitle, for: .normal)
        }
    }

    @IBOutlet private weak var forgotPasswordButton: UIButton! {
        willSet {
            newValue.setTitleColor(ColorConstants.loginDescriptionLabel, for: .normal)
            newValue.titleLabel?.font = UIFont.GTAmericaStandardRegularFont(size: 12)
            newValue.setTitle(TextConstants.loginPageForgetPasswordButtonTitle + " (?)", for: .normal)
        }
    }
    
    @IBOutlet private weak var loginButton: UIButton! {
        willSet {
            newValue.setTitle(TextConstants.loginPageLoginButtonTitle, for: .normal)
            newValue.setTitleColor(UIColor.white, for: .normal)
            newValue.titleLabel?.font = UIFont.GTAmericaStandardRegularFont(size: 14)
            newValue.backgroundColor = ColorConstants.buttonDarkBlueBackground
            newValue.isOpaque = true
        }
    }

    @IBOutlet private weak var loginTextField: BorderedWithInsetsTextField! {
        willSet {
            
            newValue.attributedPlaceholder = NSAttributedString(string: TextConstants.loginPageEmailFieldPlaceholder,
                                                                attributes: [NSAttributedStringKey.foregroundColor: ColorConstants.loginTextFieldPlaceholder])
            newValue.textColor = ColorConstants.loginTextFieldText
        }
    }

    @IBOutlet private weak var passwordTextField: BorderedWithInsetsTextField! {
        willSet {
            newValue.attributedPlaceholder = NSAttributedString(string: TextConstants.loginPagePasswordFieldPlaceholder,
                                                                attributes: [NSAttributedStringKey.foregroundColor: ColorConstants.loginTextFieldPlaceholder])
            newValue.textColor = ColorConstants.loginTextFieldText

            newValue.rightView = showHideButtonWithSpacingStackView
            newValue.rightViewMode = .always
            newValue.addTarget(self, action: #selector(passwordTextFieldTextDidChange(_:)), for: .editingChanged)
            newValue.fromRightTextInset = showHideButtonWithSpacingStackView.frame.width
        }
    }
    
    @IBOutlet private weak var captchaView: LoginCaptchaView! {
        willSet {
            newValue.layer.masksToBounds = true
            newValue.isHidden = true
        }
    }

    @IBOutlet private weak var topPageErrorView: LoginErrorBannerView! {
        willSet {
            newValue.isHidden = true
        }
    }

    @IBOutlet private weak var fastLoginButton: UIButton! {
        willSet {
            newValue.setTitle("", for: .normal)
            newValue.setBackgroundImage(UIImage(named: Locale.current.isTurkishLocale ? "login_fast_login_tr" : "login_fast_login"), for: .normal)
        }
    }

    @IBOutlet private weak var loginErrorViewContainer: UIView! {
        willSet {
            newValue.isHidden = true
        }
    }

    @IBOutlet private weak var loginErrorLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.loginErrorLabelText
            newValue.font = UIFont.GTAmericaStandardRegularFont(size: 12)
            newValue.textAlignment = .left
        }
    }

    @IBOutlet private weak var fakeLoginSpaceView: UIView! {
        willSet {
            newValue.isHidden = false
        }
    }

    @IBOutlet private weak var passwordErrorViewContainer: UIView! {
        willSet {
            newValue.isHidden = true
        }
    }

    @IBOutlet private weak var passwordErrorLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.loginErrorLabelText
            newValue.font = UIFont.GTAmericaStandardRegularFont(size: 12)
            newValue.textAlignment = .left
        }
    }

    private let spacingFromRightToShowHideButton: CGFloat = 20
    private lazy var showHideButtonWithSpacingStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 0
        stack.addArrangedSubview(showHideButton)
        let spacingView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: spacingFromRightToShowHideButton, height: spacingFromRightToShowHideButton)))
        spacingView.backgroundColor = .clear
        stack.addArrangedSubview(spacingView)
        stack.frame = CGRect(origin: .zero, size: CGSize(width: showHideButton.frame.size.width + spacingFromRightToShowHideButton, height: showHideButton.frame.size.height))
        return stack
    }()

    private lazy var showHideButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.GTAmericaStandardRegularFont(size: 12)
        button.setTitleColor(ColorConstants.loginDescriptionLabel, for: .normal)
        button.setTitle(TextConstants.loginPageShowPassword, for: .normal)
        button.addTarget(self, action: #selector(showHideButtonClicked(_:)), for: .touchUpInside)
        button.isHidden = true
        button.sizeToFit()
        return button
    }()
    private var passwordVisisble: Bool = false
    private var passwordTextFieldTextIsEmpty: Bool = true {
        didSet {
            showHideButton.isHidden = passwordTextFieldTextIsEmpty
            passwordTextField.rightViewMode = passwordTextFieldTextIsEmpty ? .never : .always
        }
    }
    
    //MARK: Vars
    var output: LoginViewOutput!
    private let keyboard = Typist.shared
    private var loginCoordinator: DGLoginCoordinator!
    
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

        #if DEBUG
        loginTextField.text = "@lifeboxtest.com"
        passwordTextField.text = "Lifebox2020"
        #endif
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = ""
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
        setupLoginCoordinator()
    }
    
    private func setupDelegates() {
        captchaView.captchaAnswerTextField.delegate = self
    }
    
    private func configureKeyboard() {
        keyboard
            .on(event: .willShow) { [weak self] options in
                guard let self = self else {
                    return
                }
                
                self.updateScroll(with: options.endFrame)
            }
            .on(event: .willHide) { [weak self] _ in
                guard let self = self else {
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
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    @objc private func showHideButtonClicked(_ button: UIButton) {
        passwordVisisble.toggle()

        showHideButton.setTitle(passwordVisisble ? TextConstants.loginPageHidePassword : TextConstants.loginPageShowPassword, for: .normal)
        showHideButton.sizeToFit()
        resizeStackViewFrameForShowHideButtonForPasswordTextField()
        passwordTextField.toggleTextFieldSecureType()
    }
    
    @IBAction private func forgotPasswordButtonTapped() {
        let popupController = PopUpController.with(title: TextConstants.loginPageForgetPasswordPageTitle,
                                                   message: TextConstants.loginPageForgetPasswordDescriptionText,
                                                   image: .none,
                                                   buttonTitle: TextConstants.loginPageForgetPasswordCloseButtonTitle,
                                                   visualStyle: PopUpVisualStyle.lbLogin)
        present(popupController, animated: false)
    }

    @IBAction private func fastLoginButtonTapped() {
        guard ReachabilityService.shared.isReachable else {
            showErrorAlert(with: TextConstants.errorAlert, subtitle: TextConstants.errorConnectedToNetwork)
            return
        }
        loginCoordinator.start()
        printLog("[LoginViewController] fastLoginButtonTapped FL login scenario started")
    }

    private func prepareForDisappear() {
        ///rootViewController's navBar is hidden. But on push we shouldn't hide it
        if !output.isPresenting {
            navigationController?.setNavigationBarHidden(true, animated: true)
        }
        output.isPresenting = false
    }

    private func showErrorAlert(with title: String?, subtitle: String?) {
        let popupController = PopUpController.with(title: title,
                                                   message: subtitle,
                                                   image: .error,
                                                   buttonTitle: TextConstants.accessibilityClose,
                                                   visualStyle: PopUpVisualStyle.lbLogin)
        present(popupController, animated: false)
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
                                        password: passwordTextField.text ?? "",
                                        rememberMe: rememberMeButton.isSelected)
        } else {
            output.sendLoginAndPasswordWithCaptcha(login: loginTextField.text ?? "",
                                                   password: passwordTextField.text ?? "",
                                                   rememberMe: rememberMeButton.isSelected,
                                                   captchaID: captchaView.currentCaptchaUUID,
                                                   captchaAnswer: captchaView.captchaAnswerTextField.text ?? "")
        }
    }

    private func resizeStackViewFrameForShowHideButtonForPasswordTextField() {
        showHideButtonWithSpacingStackView.frame = CGRect(origin: .zero, size: CGSize(width: showHideButton.frame.size.width + spacingFromRightToShowHideButton, height: showHideButton.frame.size.height))
        passwordTextField.fromRightTextInset = showHideButtonWithSpacingStackView.frame.size.width
    }
}

// MARK: -LoginCoordinatorDelegate(FastLogin)
extension LoginViewController: LoginCoordinatorDelegate {
    private var iPadAppId: String {
        return "59322"
    }

    private var iPhoneAppId: String {
        return "59320"
    }

    private var currentFastLoginServerType: DGEnvironment {
        return .prp
    }

    private func setupLoginCoordinator() {
        loginCoordinator = DGLoginCoordinator(self)
        loginCoordinator.appID = Device.isIpad ? iPadAppId : iPhoneAppId
        loginCoordinator.language = Locale.current.isTurkishLocale ? "TR" : "EN"
        loginCoordinator.environment = currentFastLoginServerType
        loginCoordinator.disableCell = true
        loginCoordinator.autoLoginOnly = false
        loginCoordinator.disableAutoLogin = true
        loginCoordinator.coordinatorDelegate = self
    }

    func dgLoginToken(_ token: String) {
        printLog("[LoginViewController] dgLoginToken FL login succeded. Passed to be")
        output.authenticateWith(flToken: token)
    }

    func dgLoginFailure(_ reason: String, errorMessage: String) {
        if reason == dgKSessionTimeout as String {
            printLog("[LoginViewController] Fast Login SDK error - SessionTimeout")
            showErrorAlert(with: TextConstants.flLoginErrorPopupTitle, subtitle: TextConstants.flLoginErrorTimeout)
        } else if reason == dgKUserExit as String {
            printLog("[LoginViewController] Fast Login SDK error - UserExit")
        } else if reason == dgKNotLoginToLoginSDK as String {
            printLog("[LoginViewController] Fast Login SDK error - dgKNotLoginToLoginSDK")
            showErrorAlert(with: TextConstants.flLoginErrorPopupTitle, subtitle: TextConstants.flLoginErorNotLoginSDK)
        } else {
            printLog("[LoginViewController] Fast Login SDK error - unknown error")
            showErrorAlert(with: TextConstants.flLoginErrorPopupTitle, subtitle: TextConstants.flLoginElseError)
        }
    }

    func dgConfigurationFailure(configError: String) {
        showErrorAlert(with: TextConstants.flLoginErrorPopupTitle, subtitle: TextConstants.errorUnknown)
    }
}

// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    @objc private func passwordTextFieldTextDidChange(_ textField: UITextField) {
        guard textField == passwordTextField else {
            return
        }
        passwordTextFieldTextIsEmpty = passwordTextField.text?.removingWhiteSpaces().isEmpty ?? true
    }

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
        if textField == loginTextField {
            loginFieldError(nil)
        } else if textField == passwordTextField {
            passwordFieldError(nil)
        } else if textField == captchaView.captchaAnswerTextField {
            captchaFieldError(nil)
        }
        hideErrorMessage()
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
            self.loginButtonToCaptchaStackViewTopConstraint.constant = 15
        }
    }
    
    func refreshCaptcha() {
        captchaView.updateCaptcha()
    }

    func showErrorAlert(with title: String?, and message: String?) {
        showErrorAlert(with: title, subtitle: message)
    }
    
    //MARK: Fields alerts processing
    func loginFieldError(_ error: String?) {
        guard let error = error else {
            loginErrorViewContainer.isHidden = true
            fakeLoginSpaceView.isHidden = false
            return
        }
        loginErrorViewContainer.isHidden = false
        fakeLoginSpaceView.isHidden = true
        loginErrorLabel.text = error
    }
    
    func passwordFieldError(_ error: String?) {
        guard let error = error else {
            passwordErrorViewContainer.isHidden = true
            return
        }
        passwordErrorViewContainer.isHidden = false
        passwordErrorLabel.text = error
    }
    
    func captchaFieldError(_ error: String?) {
        captchaView.showError(error)
    }
    
    //MARK: - Alerts processing
    
    func showErrorMessage(with text: String) {
        topPageErrorView.message = text
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.topPageErrorView.isHidden = false
            self.view.layoutIfNeeded()
        }
        
        let errorViewRect = view.convert(topPageErrorView.frame, to: view)
        scrollView.scrollRectToVisible(errorViewRect, animated: true)        
    }
    
    func hideErrorMessage() {
        topPageErrorView.isHidden = true
    }

    func failedBlockError() {
        showErrorMessage(with: TextConstants.hourBlockLoginError)
    }
}
