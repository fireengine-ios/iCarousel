import UIKit

/// used KeyboardLayoutConstraint as bottom scrollView constraint
final class ChangePasswordController: UIViewController, KeyboardHandler, NibInit {
    
    // MARK: - Properties
    
    @IBOutlet private weak var scrollView: UIScrollView! {
        willSet {
            newValue.delaysContentTouches = false
        }
    }
    
    @IBOutlet private weak var passwordsStackView: UIStackView! {
        willSet {
            newValue.spacing = 18
            newValue.axis = .vertical
            newValue.alignment = .fill
            newValue.distribution = .fill
            newValue.backgroundColor = .white
            newValue.isOpaque = true
            
            newValue.addArrangedSubview(oldPasswordView)
            newValue.addArrangedSubview(newPasswordView)
            newValue.addArrangedSubview(repeatPasswordView)
        }
    }
    
    @IBOutlet private weak var captchaView: CaptchaView!
    
    private let oldPasswordView: PasswordView = {
        let view = PasswordView.initFromNib()
        view.titleLabel.text = TextConstants.oldPassword
        view.passwordTextField.placeholder = TextConstants.enterYourOldPassword
        view.passwordTextField.returnKeyType = .next
        return view
    }()
    
    private let newPasswordView: PasswordView = {
        let view = PasswordView.initFromNib()
        view.titleLabel.text = TextConstants.newPassword
        view.passwordTextField.placeholder = TextConstants.enterYourNewPassword
        view.passwordTextField.returnKeyType = .next
        return view
    }()
    
    private let repeatPasswordView: PasswordView = {
        let view = PasswordView.initFromNib()
        view.titleLabel.text = TextConstants.repeatPassword
        view.passwordTextField.placeholder = TextConstants.enterYourRepeatPassword
        view.passwordTextField.returnKeyType = .next
        return view
    }()
    
    private lazy var accountService = AccountService()
    private lazy var authenticationService = AuthenticationService()
    private var showErrorColorInNewPasswordView = false
    
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
        oldPasswordView.passwordTextField.delegate = self
        newPasswordView.passwordTextField.delegate = self
        repeatPasswordView.passwordTextField.delegate = self
        captchaView.captchaAnswerTextField.delegate = self
        
        addTapGestureToHideKeyboard()
        
        let doneButton = UIBarButtonItem(title: TextConstants.accessibilityDone,
                                         font: UIFont.TurkcellSaturaDemFont(size: 19),
                                         tintColor: .white,
                                         accessibilityLabel: TextConstants.accessibilityDone,
                                         style: .plain,
                                         target: self,
                                         selector: #selector(onDoneButton))
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
            let oldPassword = oldPasswordView.passwordTextField.text,
            let newPassword = newPasswordView.passwordTextField.text,
            let repeatPassword = repeatPasswordView.passwordTextField.text,
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
                                            switch result {
                                            case .success(_):
                                                self?.getAccountInfo()
                                            case .failure(let error):
                                                self?.actionOnUpdateOnError(error)
                                                self?.hideSpinnerIncludeNavigationBar()
                                                self?.captchaView.updateCaptcha()
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
    
    private func loginIfCan(with login: String) {
        guard let newPassword = newPasswordView.passwordTextField.text else {
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
        RouterVC().presentViewController(controller: popupVC)
    }
    
    private func showSuccessPopup() {
        let popupVC = PopUpController.with(title: TextConstants.passwordChangedSuccessfully,
                                           message: nil,
                                           image: .success,
                                           buttonTitle: TextConstants.ok,
                                           action: { vc in
                                            vc.close  {
                                                RouterVC().popViewController()
                                            }
        })
        RouterVC().presentViewController(controller: popupVC)
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
             .uppercaseMissInPassword,
             .lowercaseMissInPassword,
             .numberMissInPassword:
            showErrorColorInNewPasswordView = true
            
            /// important check to show error only once
            if newPasswordView.passwordTextField.isFirstResponder {
                updateNewPasswordView()
            }
            
            newPasswordView.showTextAnimated(text: errorText)
            newPasswordView.passwordTextField.becomeFirstResponder()
            scrollToView(newPasswordView)
            
        case .invalidOldPassword,
             .oldPasswordIsEmpty:
            oldPasswordView.showTextAnimated(text: errorText)
            oldPasswordView.passwordTextField.becomeFirstResponder()
            scrollToView(oldPasswordView)
            
        case .notMatchNewAndRepeatPassword,
             .repeatPasswordIsEmpty:
            repeatPasswordView.showTextAnimated(text: errorText)
            repeatPasswordView.passwordTextField.becomeFirstResponder()
            scrollToView(repeatPasswordView)
            
        case .special, .unknown:
            UIApplication.showErrorAlert(message: errorText)
        }
    }
    
    private func scrollToView(_ view: UIView) {
        let rect = scrollView.convert(view.frame, to: scrollView)
        scrollView.scrollRectToVisible(rect, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension ChangePasswordController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case newPasswordView.passwordTextField:
            updateNewPasswordView()
        default:
            break
        }
    }
    
    private func updateNewPasswordView() {
        if showErrorColorInNewPasswordView {
            newPasswordView.underlineLabel.textColor = ColorConstants.textOrange
            /// we need to show error with color just once
            showErrorColorInNewPasswordView = false
            
        /// can be "else" only. added check for optimization without additional flags
        } else if newPasswordView.underlineLabel.textColor != UIColor.lrTealish {
            newPasswordView.underlineLabel.textColor = UIColor.lrTealish
            newPasswordView.underlineLabel.text = TextConstants.errorInvalidPassword
        }
        newPasswordView.showUnderlineAnimated()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case newPasswordView.passwordTextField:
            newPasswordView.hideUnderlineAnimated()
        case oldPasswordView.passwordTextField:
            oldPasswordView.hideUnderlineAnimated()
        case repeatPasswordView.passwordTextField:
            repeatPasswordView.hideUnderlineAnimated()
        case captchaView.captchaAnswerTextField:
            captchaView.hideErrorAnimated()
        default:
            assertionFailure()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case oldPasswordView.passwordTextField:
            newPasswordView.passwordTextField.becomeFirstResponder()
        case newPasswordView.passwordTextField:
            repeatPasswordView.passwordTextField.becomeFirstResponder()
        case repeatPasswordView.passwordTextField:
            captchaView.captchaAnswerTextField.becomeFirstResponder()
        case captchaView.captchaAnswerTextField:
            updatePassword()
        default:
            assertionFailure()
        }
        
        return true
    }
}
