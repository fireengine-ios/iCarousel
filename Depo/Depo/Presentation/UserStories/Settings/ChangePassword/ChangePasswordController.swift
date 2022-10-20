import UIKit

/// used KeyboardLayoutConstraint as bottom scrollView constraint
final class ChangePasswordController: BaseViewController, KeyboardHandler, NibInit {
    
    // MARK: - Properties
    
    @IBOutlet private weak var scrollView: UIScrollView! {
        willSet {
            newValue.delaysContentTouches = false
        }
    }
    
    @IBOutlet private weak var passwordsStackView: UIStackView! {
        willSet {
            newValue.spacing = 22
            newValue.axis = .vertical
            newValue.alignment = .fill
            newValue.distribution = .fill
            newValue.backgroundColor = AppColor.primaryBackground.color
            newValue.isOpaque = true
            
            newValue.addArrangedSubview(oldPasswordView)
            newValue.addArrangedSubview(validationSet)
        }
    }
    
    @IBOutlet private weak var captchaView: CaptchaView!
    
    private lazy var oldPasswordView: ProfilePasswordEnterView = {
        let view = ProfilePasswordEnterView()
        view.titleLabel.text = TextConstants.oldPassword
        view.textField.placeholder = TextConstants.enterYourOldPassword
        view.textField.returnKeyType = .next
        return view
    }()
    
    private lazy var validationSet: PasswordValidationSetView = {
        let view = PasswordValidationSetView()
        
        return view
    }()
    
    private lazy var accountService = AccountService()
    private lazy var authenticationService = AuthenticationService()
    private lazy var router = RouterVC()
    private var showErrorColorInNewPasswordView = false
    private var doneButton: UIBarButtonItem?
    
    // MARK: - View methods
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        initSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSetup()
    }
    
    private func initSetup() {
        title = TextConstants.userProfileChangePassword
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        trackScreen()
        initialViewSetup()
    }
    
    private func initialViewSetup() {
        oldPasswordView.textField.delegate = self
        captchaView.captchaAnswerTextField.delegate = self
        validationSet.delegate = self
        
        addTapGestureToHideKeyboard()
        
        doneButton = UIBarButtonItem(title: TextConstants.accessibilityDone,
                                     font: UIFont.TurkcellSaturaDemFont(size: 19),
                                     tintColor: .white,
                                     accessibilityLabel: TextConstants.accessibilityDone,
                                     style: .plain,
                                     target: self,
                                     selector: #selector(onDoneButton))
        doneButton?.isEnabled = false
        navigationItem.rightBarButtonItem = doneButton
    }
    

    @objc private func onDoneButton(_ button: UIBarButtonItem) {
        updatePassword()
    }
    
    //MARK: - Tracking/loging
    
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    private func trackScreen() {
        analyticsService.logScreen(screen: .changePassword)
    }
    
    // MARK: - API
    
    private func updatePassword() {
        
        guard
            let oldPassword = oldPasswordView.textField.text,
            let newPassword = validationSet.newPasswordView.textField.text,
            let repeatPassword = validationSet.rePasswordView.textField.text,
            let captchaAnswer = captchaView.captchaAnswerTextField.text
        else {
            assertionFailure("all fields should not be nil")
            return
        }
        
        if oldPassword.isEmpty {
            actionOnUpdateOnError(.oldPasswordIsEmpty)
        } else if newPassword.isEmpty {
            actionOnUpdateOnError(.newPasswordIsEmpty)
        } else if repeatPassword.isEmpty {
            actionOnUpdateOnError(.repeatPasswordIsEmpty)
        } else if newPassword != repeatPassword {
            actionOnUpdateOnError(.notMatchNewAndRepeatPassword)
        } else if captchaAnswer.isEmpty {
            actionOnUpdateOnError(.captchaAnswerIsEmpty)
        } else {
            showSpinnerIncludeNavigationBar()
            
            accountService.updatePassword(oldPassword: oldPassword,
                                          newPassword: newPassword,
                                          repeatPassword: repeatPassword,
                                          captchaId: captchaView.currentCaptchaUUID,
                                          captchaAnswer: captchaAnswer) { [weak self] result in
                                            guard let self = self else {
                                                return
                                            }
                                            switch result {
                                            case .success(_):
                                                self.getAccountInfo()
                                                self.trackProfilePasswordChange()
                                            case .failure(let error):
                                                self.actionOnUpdateOnError(error)
                                                self.hideSpinnerIncludeNavigationBar()
                                                self.captchaView.updateCaptcha()
                                            }
            }
            
        }
    }
    
    private func getAccountInfo() {
        accountService.info(success: { [weak self] (response) in
            guard let response = response as? AccountInfoResponse else {
                let error = CustomErrors.serverError("An error occured while getting account info")
                self?.showError(error)
                return
            }
            let login = response.email ?? response.fullPhoneNumber
            self?.loginIfCan(with: login)
        }, fail: { [weak self] error in
            self?.showError(error)
        })
    }
    
    private func trackProfilePasswordChange() {
        analyticsService.trackProfileUpdateGAEvent(editFields: GAEventLabel.ProfileChangeType.password.text)
    }
    
    private func loginIfCan(with login: String) {
        guard let newPassword = validationSet.newPasswordView.textField.text else {
            assertionFailure("all fields should not be nil")
            return
        }
        
        let user = AuthenticationUser(login: login,
                                      password: newPassword,
                                      rememberMe: true,
                                      attachedCaptcha: nil)
        
        authenticationService.login(user: user, sucess: { [weak self] headers in
            /// on main queue
            self?.showSuccessPopup()
            self?.hideSpinnerIncludeNavigationBar()
            }, fail: { [weak self] errorResponse  in
                if errorResponse.description.contains("Captcha required") {
                    self?.showLogoutPopup()
                    self?.hideSpinnerIncludeNavigationBar()
                } else {
                    self?.showError(errorResponse)
                }
            }, twoFactorAuth: { twoFARequered in
                
            /// As a result of the meeting, the logic of showing the screen of two factorial authorization is added only with a direct login and is not used with other authorization methods.
                assertionFailure()
        })
    }
    
    // MARK: - Show
    
    private func showLogoutPopup() {
        let popupVC = PopUpController.with(title: TextConstants.passwordChangedSuccessfullyRelogin,
                                           message: nil,
                                           image: .success,
                                           buttonTitle: TextConstants.ok,
                                           action: { vc in
                                            vc.close {
                                                AppConfigurator.logout()
                                            }
        })
        popupVC.open()

    }
    
    private func showSuccessPopup() {
        SnackbarManager.shared.show(type: .nonCritical, message: TextConstants.passwordChangedSuccessfully)
        router.popViewController()
    }
    
    private func showError(_ errorResponse: Error) {
        captchaView.updateCaptcha()
        UIApplication.showErrorAlert(message: errorResponse.description)
        hideSpinnerIncludeNavigationBar()
    }
    
    private func actionOnUpdateOnError(_ error: UpdatePasswordErrors) {
        let errorText = error.localizedDescription
        
        switch error {
        case .invalidCaptcha,
             .captchaAnswerIsEmpty:
            captchaView.showErrorAnimated(text: errorText)
            captchaView.captchaAnswerTextField.becomeFirstResponder()
            scrollToView(captchaView)
            
        case .invalidNewPassword,
             .newPasswordIsEmpty,
             .passwordInResentHistory,
             .uppercaseMissingInPassword,
             .lowercaseMissingInPassword,
             .passwordIsEmpty,
             .passwordLengthIsBelowLimit,
             .passwordLengthExceeded,
             .passwordSequentialCaharacters,
             .passwordSameCaharacters,
             .numberMissingInPassword:
            showErrorColorInNewPasswordView = true
            
            /// important check to show error only once
            if validationSet.newPasswordView.textField.isFirstResponder {
                updateNewPasswordView()
            }
            
            validationSet.newPasswordView.showSubtitleTextAnimated(text: errorText)
            validationSet.newPasswordView.textField.becomeFirstResponder()
            scrollToView(validationSet.newPasswordView)
            
        case .invalidOldPassword,
             .oldPasswordIsEmpty:
            oldPasswordView.showSubtitleTextAnimated(text: errorText)
            oldPasswordView.textField.becomeFirstResponder()
            scrollToView(oldPasswordView)
            
        case .notMatchNewAndRepeatPassword,
             .repeatPasswordIsEmpty:
            validationSet.rePasswordView.showSubtitleTextAnimated(text: errorText)
            validationSet.rePasswordView.textField.becomeFirstResponder()
            scrollToView(validationSet.rePasswordView)
            
        case .special, .unknown,
             .invalidToken,
             .externalAuthTokenRequired,
             .forgetPasswordRequired,
             .emailDomainNotAllowed:
            UIApplication.showErrorAlert(message: errorText)
        }
    }
    
    private func scrollToView(_ view: UIView) {
        let rect = scrollView.convert(view.frame, to: scrollView)
        scrollView.scrollRectToVisible(rect, animated: true)
    }
}

// MARK: - PasswordValidationSetDelegate
extension ChangePasswordController: PasswordValidationSetDelegate {
    func validateNewPassword(with flag: Bool) {
        doneButton?.isEnabled = flag
    }
}

// MARK: - UITextFieldDelegate
extension ChangePasswordController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case validationSet.newPasswordView.textField:
            updateNewPasswordView()
        default:
            break
        }
    }
    
    private func updateNewPasswordView() {
        if showErrorColorInNewPasswordView {
            //newPasswordView.errorLabel.textColor = ColorConstants.textOrange
            /// we need to show error with color just once
            showErrorColorInNewPasswordView = false
        }
        validationSet.newPasswordView.showSubtitleAnimated()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case validationSet.newPasswordView.textField:
            validationSet.newPasswordView.hideSubtitleAnimated()
        case oldPasswordView.textField:
            oldPasswordView.hideSubtitleAnimated()
        case validationSet.rePasswordView.textField:
            validationSet.rePasswordView.hideSubtitleAnimated()
        case captchaView.captchaAnswerTextField:
            captchaView.hideErrorAnimated()
        default:
            assertionFailure()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case oldPasswordView.textField:
            validationSet.newPasswordView.textField.becomeFirstResponder()
        case validationSet.newPasswordView.textField:
            validationSet.rePasswordView.textField.becomeFirstResponder()
        case validationSet.rePasswordView.textField:
            captchaView.captchaAnswerTextField.becomeFirstResponder()
        case captchaView.captchaAnswerTextField:
            updatePassword()
        default:
            assertionFailure()
        }
        
        return true
    }
}
