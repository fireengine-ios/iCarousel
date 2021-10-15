import UIKit

final class PasswordView: UIView, NibInit {
    
    private let openedEyeImage = UIImage(named: "ic_eye_show")
    private let closedEyeImage = UIImage(named: "ic_eye_hide")
    var isNeedToShowRules = false {
        willSet {
            if newValue {
                rulesLabel.text = TextConstants.signUpPasswordRulesLabel
            }
        }
    }

    @IBOutlet private weak var showPasswordButton: UIButton! {
        willSet {
            /// in IB: UIButton(type: .custom)
            newValue.isExclusiveTouch = true
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 16)
            newValue.setTitleColor(UIColor.lrTealish, for: .normal)
            newValue.setTitleColor(UIColor.lrTealish.lighter(by: 30), for: .highlighted)
            newValue.backgroundColor = AppColor.primaryBackground.color
            newValue.isOpaque = true
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel! {
        willSet {
            newValue.textColor = UIColor.lrTealish
            newValue.font = UIFont.TurkcellSaturaBolFont(size: 16)
            newValue.backgroundColor = AppColor.primaryBackground.color
            newValue.isOpaque = true
        }
    }
    
    @IBOutlet weak var errorLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.textOrange
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 15)
            newValue.isHidden = true
            newValue.backgroundColor = AppColor.primaryBackground.color
            newValue.isOpaque = true
            newValue.numberOfLines = 0
        }
    }
    
    @IBOutlet private weak var rulesLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaFont(size: 14)
            newValue.textColor = ColorConstants.lightText
            newValue.numberOfLines = 0
        }
    }
    
    @IBOutlet weak var passwordTextField: UITextField! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 18)
            newValue.isSecureTextEntry = true
            newValue.textColor = AppColor.blackColor.color
            newValue.borderStyle = .none
            newValue.backgroundColor = AppColor.primaryBackground.color
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
        errorLabel.text = ""
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureButton()
    }
    
    func showErrorLabelAnimated() {
        guard errorLabel.isHidden else {
            return
        }
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.errorLabel.isHidden = false
            /// https://stackoverflow.com/a/46412621/5893286
            self.layoutIfNeeded()
        }
    }
    
    func hideErrorLabelAnimated() {
        guard !errorLabel.isHidden else {
            return
        }
        layoutIfNeeded()
        errorLabel.text = ""
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.errorLabel.isHidden = true
            /// https://stackoverflow.com/a/46412621/5893286
            self.layoutIfNeeded()
        }
    }
    
    func showTextAnimated(text: String) {
        errorLabel.text = text
        showErrorLabelAnimated()
    }
}
