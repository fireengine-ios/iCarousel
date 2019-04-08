import UIKit

final class PasswordView: UIView, NibInit {
    
    @IBOutlet private weak var showPasswordButton: UIButton! {
        willSet {
            /// in IB: UIButton(type: .custom)
            newValue.isExclusiveTouch = true
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 16)
            newValue.setTitleColor(ColorConstants.lightText, for: .normal)
            newValue.setTitleColor(ColorConstants.lightText.lighter(by: 30), for: .highlighted)
            newValue.backgroundColor = .white
            newValue.isOpaque = true
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.lightText
            newValue.font = UIFont.TurkcellSaturaBolFont(size: 16)
            newValue.backgroundColor = .white
            newValue.isOpaque = true
        }
    }
    
    @IBOutlet weak var underlineLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.textOrange
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 15)
            newValue.isHidden = true
            newValue.backgroundColor = .white
            newValue.isOpaque = true
        }
    }
    
    @IBOutlet weak var passwordTextField: UITextField! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaBolFont(size: 21)
            newValue.textColor = UIColor.lrTealish
            newValue.borderStyle = .none
            newValue.backgroundColor = .white
            newValue.isOpaque = true
        }
    }
    
    @IBOutlet private weak var lineView: UIView! {
        willSet {
            newValue.backgroundColor = ColorConstants.lightText
            newValue.isOpaque = true
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
    
    func showUnderlineAnimated() {
        guard underlineLabel.isHidden else {
            return
        }
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.underlineLabel.isHidden = false
            /// https://stackoverflow.com/a/46412621/5893286
            self.layoutIfNeeded()
        }
    }
    
    func hideUnderlineAnimated() {
        guard !underlineLabel.isHidden else {
            return
        }
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.underlineLabel.isHidden = true
            /// https://stackoverflow.com/a/46412621/5893286
            self.layoutIfNeeded()
        }
    }
    
    func showTextAnimated(text: String) {
        underlineLabel.text = text
        showUnderlineAnimated()
    }
}
