import UIKit

final class ChangePasswordController: UIViewController, KeyboardHandler {
    
    @IBOutlet private weak var passwordsStackView: UIStackView! {
        willSet {
            newValue.spacing = 20
            newValue.axis = .vertical
            newValue.alignment = .fill
            newValue.distribution = .fill
            
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
        return view
    }()
    
    private let repeatPasswordView: PasswordView = {
        let view = PasswordView.initFromNib()
        view.titleLabel.text = "Re-Enter Password"
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTapGestureToHideKeyboard()
    }
}
