import UIKit

final class ChangePasswordController: UIViewController, KeyboardHandler, NibInit {
    
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
        view.passwordTextField.returnKeyType = .next
        return view
    }()
    
    private let newPasswordView: PasswordView = {
        let view = PasswordView.initFromNib()
        view.titleLabel.text = TextConstants.newPassword
        view.passwordTextField.returnKeyType = .next
        return view
    }()
    
    private let repeatPasswordView: PasswordView = {
        let view = PasswordView.initFromNib()
        view.titleLabel.text = TextConstants.repeatPassword
        view.passwordTextField.returnKeyType = .next
        return view
    }()
    
    private lazy var accountService = AccountService()
    private var showErrorColorInNewPasswordView = false
    
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
        } else if captchaAnswer.isEmpty {
            actionOnUpdateOnError(.captchaAnswerIsEmpty)
        } else {
            showSpinner()
            
            accountService.updatePassword(oldPassword: oldPassword,
                                          newPassword: newPassword,
                                          repeatPassword: repeatPassword,
                                          captchaId: captchaView.currentCaptchaUUID,
                                          captchaAnswer: captchaAnswer) { [weak self] result in
                                            switch result {
                                            case .success(_):
                                                RouterVC().popViewController()
                                            case .failure(let error):
                                                self?.actionOnUpdateOnError(error)
                                            }
                                            self?.hideSpinner()
                                            self?.captchaView.updateCaptcha()
            }
            
        }
    }
    
    private func actionOnUpdateOnError(_ error: UpdatePasswordErrors) {
        let errorText = error.localizedDescription
        
        switch error {
        case .unknown, .invalidCaptcha, .captchaAnswerIsEmpty:
            captchaView.showErrorAnimated(text: errorText)
            captchaView.captchaAnswerTextField.becomeFirstResponder()
            scrollToView(captchaView)
            
        case .invalidNewPassword, .newPasswordIsEmpty:
            showErrorColorInNewPasswordView = true
            
            /// important check to show error only once
            if newPasswordView.passwordTextField.isFirstResponder {
                updateNewPasswordView()
            }
            
            newPasswordView.showTextAnimated(text: errorText)
            newPasswordView.passwordTextField.becomeFirstResponder()
            scrollToView(newPasswordView)
            
        case .invalidOldPassword, .oldPasswordIsEmpty:
            oldPasswordView.showTextAnimated(text: errorText)
            oldPasswordView.passwordTextField.becomeFirstResponder()
            scrollToView(oldPasswordView)
            
        case .notMatchNewAndRepeatPassword, .repeatPasswordIsEmpty:
            repeatPasswordView.showTextAnimated(text: errorText)
            repeatPasswordView.passwordTextField.becomeFirstResponder()
            scrollToView(repeatPasswordView)
        }
    }
    
    private func scrollToView(_ view: UIView) {
        let rect = scrollView.convert(view.frame, to: scrollView)
        scrollView.scrollRectToVisible(rect, animated: true)
    }
}

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
            
        /// can be "else" only. added chech for optimization without additional flags
        } else if newPasswordView.underlineLabel.textColor != UIColor.lrTealish {
            newPasswordView.underlineLabel.textColor = UIColor.lrTealish
            newPasswordView.underlineLabel.text = TextConstants.registrationPasswordError
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
