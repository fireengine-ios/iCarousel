import UIKit

final class ChangePasswordController: UIViewController, KeyboardHandler {
    
    @IBOutlet private weak var scrollView: UIScrollView! {
        willSet {
            newValue.delaysContentTouches = false
        }
    }
    
    @IBOutlet private weak var passwordsStackView: UIStackView! {
        willSet {
            newValue.spacing = 20
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
        view.titleLabel.text = "Old Password"
        view.passwordTextField.returnKeyType = .next
        return view
    }()
    
    private let newPasswordView: PasswordView = {
        let view = PasswordView.initFromNib()
        view.titleLabel.text = "New Password"
        view.underlineLabel.text = "Please set a password including nonconsecutive letters and numbers, minimum 6 maximum 16 characters."
        view.passwordTextField.returnKeyType = .next
        return view
    }()
    
    private let repeatPasswordView: PasswordView = {
        let view = PasswordView.initFromNib()
        view.titleLabel.text = "Re-Enter Password"
        view.passwordTextField.returnKeyType = .next
        return view
    }()
    
    private lazy var accountService = AccountService()
    private var showErrorColorNewPasswordView = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
//        oldPasswordView.passwordTextField.text = "qwerty"
//        newPasswordView.passwordTextField.text = "qwertyu"
//        repeatPasswordView.passwordTextField.text = "qwerty"
    }
    
    private func initialSetup() {
        oldPasswordView.passwordTextField.delegate = self
        newPasswordView.passwordTextField.delegate = self
        repeatPasswordView.passwordTextField.delegate = self
        captchaView.captchaAnswerTextField.delegate = self
        
        addTapGestureToHideKeyboard()
        
        let doneButton = UIBarButtonItem(title: "Done",
                                         font: UIFont.TurkcellSaturaDemFont(size: 19),
                                         tintColor: .white,
                                         accessibilityLabel: "Done",
                                         style: .plain,
                                         target: self,
                                         selector: #selector(onDoneButton))
        navigationItem.rightBarButtonItem = doneButton
    }
    
    @objc private func onDoneButton(_ button: UIBarButtonItem) {
//        button.isEnabled = false
        //activity
        //service call
        updatePassword()
    }
    
    func updatePassword() {
        
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
            
            accountService.updatePassword(oldPassword: oldPassword,
                                          newPassword: newPassword,
                                          repeatPassword: repeatPassword,
                                          captchaId: captchaView.currentCaptchaUUID,
                                          captchaAnswer: captchaAnswer) { [weak self] result in
                                            switch result {
                                            case .success(_):
                                                print("success")
                                            case .failure(let error):
                                                self?.actionOnUpdateOnError(error)
                                            }
            }
        }
    }
    
    private func actionOnUpdateOnError(_ error: UpdatePasswordErrors) {
        let errorText = error.localizedDescription
        
        switch error {
        case .unknown, .invalidCaptcha, .captchaAnswerIsEmpty:
            captchaView.updateCaptcha()
            captchaView.showErrorAnimated(text: errorText)
            captchaView.captchaAnswerTextField.becomeFirstResponder()
            let rect = scrollView.convert(captchaView.frame, to: scrollView)
            scrollView.scrollRectToVisible(rect, animated: true)
            
        case .invalidNewPassword, .newPasswordIsEmpty:
//            newPasswordView.underlineLabel.textColor = ColorConstants.textOrange
            showErrorColorNewPasswordView = true
            
            newPasswordView.showTextAnimated(text: errorText)
            newPasswordView.passwordTextField.becomeFirstResponder()
            let rect = scrollView.convert(newPasswordView.frame, to: scrollView)
            scrollView.scrollRectToVisible(rect, animated: true)
            
        case .invalidOldPassword, .oldPasswordIsEmpty:
            oldPasswordView.showTextAnimated(text: errorText)
            oldPasswordView.passwordTextField.becomeFirstResponder()
            let rect = scrollView.convert(oldPasswordView.frame, to: scrollView)
            scrollView.scrollRectToVisible(rect, animated: true)
            
        case .notMatchNewAndRepeatPassword, .repeatPasswordIsEmpty:
            repeatPasswordView.showTextAnimated(text: errorText)
            repeatPasswordView.passwordTextField.becomeFirstResponder()
            let rect = scrollView.convert(repeatPasswordView.frame, to: scrollView)
            scrollView.scrollRectToVisible(rect, animated: true)
        }
        
        print(errorText)
    }
}

extension ChangePasswordController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case newPasswordView.passwordTextField:
            if showErrorColorNewPasswordView {
                newPasswordView.underlineLabel.textColor = ColorConstants.textOrange
                showErrorColorNewPasswordView = false
            } else {
                newPasswordView.underlineLabel.textColor = UIColor.lrTealish
            }
            newPasswordView.showUnderlineAnimated()
            
        default:
            break
        }
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
