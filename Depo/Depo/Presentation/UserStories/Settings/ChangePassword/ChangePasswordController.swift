import UIKit

final class ChangePasswordController: UIViewController, KeyboardHandler {
    
    /// in IB:
    /// UIScrollView().delaysContentTouches = false
    
    private lazy var accountService = AccountService()
    
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
        view.underlineLabel.textColor = UIColor.lrTealish
        view.passwordTextField.returnKeyType = .next
        return view
    }()
    
    private let repeatPasswordView: PasswordView = {
        let view = PasswordView.initFromNib()
        view.titleLabel.text = "Re-Enter Password"
        view.passwordTextField.returnKeyType = .next
        return view
    }()
    
    @IBOutlet private weak var captchaView: CaptchaView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
        oldPasswordView.passwordTextField.text = "qwerty"
        newPasswordView.passwordTextField.text = "qwertyu"
        repeatPasswordView.passwordTextField.text = "qwerty"
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
        
        accountService.updatePassword(oldPassword: oldPassword,
                                      newPassword: newPassword,
                                      repeatPassword: repeatPassword,
                                      captchaId: captchaView.currentCaptchaUUID,
                                      captchaAnswer: captchaAnswer) { result in
                                        switch result {
                                        case .success(_):
                                            print("success")
                                        case .failure(let error):
                                            print(error)
                                        }
        }
    }
}

extension ChangePasswordController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case newPasswordView.passwordTextField:
            UIView.animate(withDuration: NumericConstants.animationDuration) {
                self.newPasswordView.underlineLabel.isHidden = false
                /// https://stackoverflow.com/a/46412621/5893286
                self.passwordsStackView.layoutIfNeeded()
            }
            
        default:
            break
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case newPasswordView.passwordTextField:
            UIView.animate(withDuration: NumericConstants.animationDuration) {
                self.newPasswordView.underlineLabel.isHidden = true
                /// https://stackoverflow.com/a/46412621/5893286
                self.passwordsStackView.layoutIfNeeded()
            }
        default:
            break
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
