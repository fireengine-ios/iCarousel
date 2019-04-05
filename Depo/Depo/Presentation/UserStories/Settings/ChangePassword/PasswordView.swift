import UIKit

final class PasswordView: UIView, NibInit {
    
    @IBOutlet private weak var showPasswordButton: UIButton! {
        willSet {
            newValue.isExclusiveTouch = true
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 16)
            newValue.setTitleColor(ColorConstants.lightText, for: .normal)
            newValue.setTitleColor(ColorConstants.lightText.darker(by: 30), for: .highlighted)
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.lightText
            newValue.font = UIFont.TurkcellSaturaBolFont(size: 16)
        }
    }
    
    @IBOutlet weak var errorLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.textOrange
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 15)
            newValue.isHidden = true
        }
    }
    
    @IBOutlet private weak var passwordTextField: UITextField! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaBolFont(size: 21)
            newValue.textColor = UIColor.lrTealish
            newValue.borderStyle = .none
        }
    }
    
    @IBOutlet private weak var lineView: UIView! {
        willSet {
            newValue.backgroundColor = ColorConstants.lightText
        }
    }
    
    @IBAction private func onShowPasswordButton(_ sender: UIButton) {
        toggleTextFieldSecureType()
    }
    
    private func toggleTextFieldSecureType() {
        passwordTextField.isSecureTextEntry.toggle()
        
        let showPasswordButtonText = passwordTextField.isSecureTextEntry ? "Show" : "Hide"
        showPasswordButton.setTitle(showPasswordButtonText, for: .normal)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        toggleTextFieldSecureType()
    }
}

extension UITextField {
    func toggleTextFieldSecureType() {
        isSecureTextEntry.toggle()
        
        /// https://stackoverflow.com/a/35295940/5893286
        let font = self.font
        self.font = nil
        self.font = font
    }
}
