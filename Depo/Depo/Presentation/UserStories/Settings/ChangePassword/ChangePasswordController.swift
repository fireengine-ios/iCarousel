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
    
    @IBOutlet weak var captchaAnswerTextField: InsetsTextField! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaItaFont(size: 20)
            newValue.textColor = UIColor.lrTealish
            newValue.borderStyle = .none
            newValue.backgroundColor = .white
            newValue.isOpaque = true
            newValue.insetX = 16
            newValue.attributedPlaceholder = NSAttributedString(string: "Type the text",
                                                                attributes: [.foregroundColor: UIColor.lrTealish])
            
            newValue.layer.cornerRadius = 5
            newValue.layer.borderWidth = 1
            newValue.layer.borderColor = ColorConstants.darkBorder.cgColor
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newPasswordView.passwordTextField.delegate = self
        addTapGestureToHideKeyboard()
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(qq))
//        view.addGestureRecognizer(tapGesture)
    }
    
//    @objc func qq() {
//        view.endEditing(true)
//    }
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
