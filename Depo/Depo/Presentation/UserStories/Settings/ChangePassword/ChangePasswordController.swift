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
            
            newValue.returnKeyType = .done
            
            /// removes suggestions bar above keyboard
            newValue.autocorrectionType = .no
            
            /// removed useless features
            newValue.autocapitalizationType = .none
            newValue.spellCheckingType = .no
            newValue.autocapitalizationType = .none
            newValue.enablesReturnKeyAutomatically = true
            if #available(iOS 11.0, *) {
                newValue.smartQuotesType = .no
                newValue.smartDashesType = .no
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
    }
    
    private func initialSetup() {
        oldPasswordView.passwordTextField.delegate = self
        newPasswordView.passwordTextField.delegate = self
        repeatPasswordView.passwordTextField.delegate = self
        captchaAnswerTextField.delegate = self
        
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
    
    @objc private func onDoneButton() {
        //activity
        //service call
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
            captchaAnswerTextField.becomeFirstResponder()
        case captchaAnswerTextField:
            onDoneButton()
        default:
            break
        }
            
        return true
    }
}
