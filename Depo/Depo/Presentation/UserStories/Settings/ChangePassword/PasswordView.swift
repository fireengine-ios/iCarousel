import UIKit

final class PasswordView: UIView, NibInit {
    
    private let openedEyeImage = UIImage(named: "ic_eye_show")
    private let closedEyeImage = UIImage(named: "ic_eye_hide")

    @IBOutlet private weak var showPasswordButton: UIButton! {
        willSet {
            /// in IB: UIButton(type: .custom)
            newValue.isExclusiveTouch = true
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 16)
            newValue.setTitleColor(UIColor.lrTealish, for: .normal)
            newValue.setTitleColor(UIColor.lrTealish.lighter(by: 30), for: .highlighted)
            newValue.backgroundColor = .white
            newValue.isOpaque = true
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel! {
        willSet {
            newValue.textColor = UIColor.lrTealish
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
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 18)
            newValue.isSecureTextEntry = true
            newValue.textColor = UIColor.black
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
        toggleSecureType()
    }
    
    /// can be optmized with one check of "passwordTextField.isSecureTextEntry"
    private func toggleSecureType() {
        passwordTextField.toggleTextFieldSecureType()
        showPasswordButton.isSelected.toggle()
    }
    
    private func configureButton() {
        showPasswordButton.setImage(openedEyeImage, for: .normal)
        showPasswordButton.setImage(closedEyeImage, for: .selected)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureButton()
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
