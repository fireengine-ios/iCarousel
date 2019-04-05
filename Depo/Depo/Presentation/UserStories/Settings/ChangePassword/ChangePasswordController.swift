import UIKit

final class ChangePasswordController: UIViewController, KeyboardHandler {
    
    /// in IB:
    /// UIScrollView().delaysContentTouches = false
    
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
        return view
    }()
    
    private let newPasswordView: PasswordView = {
        let view = PasswordView.initFromNib()
        view.titleLabel.text = "New Password"
        view.errorLabel.text = "Please set a password including nonconsecutive letters and numbers, minimum 6 maximum 16 characters."
        view.errorLabel.textColor = UIColor.lrTealish
        return view
    }()
    
    private let repeatPasswordView: PasswordView = {
        let view = PasswordView.initFromNib()
        view.titleLabel.text = "Re-Enter Password"
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newPasswordView.passwordTextField.delegate = self
        //addTapGestureToHideKeyboard()
    }
}

extension ChangePasswordController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case newPasswordView.passwordTextField:
            UIView.animate(withDuration: NumericConstants.animationDuration) {
                self.newPasswordView.errorLabel.isHidden = false
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
                self.newPasswordView.errorLabel.isHidden = true
                /// https://stackoverflow.com/a/46412621/5893286
                self.passwordsStackView.layoutIfNeeded()
            }
        default:
            break
        }
    }
}
