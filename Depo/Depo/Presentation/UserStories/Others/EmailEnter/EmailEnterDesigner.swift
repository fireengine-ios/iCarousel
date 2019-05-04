import UIKit

final class EmailEnterDesigner: NSObject {
    @IBOutlet private weak var infoLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.pleaseEnterYourMissingAccountInformation
            newValue.textColor = UIColor.black
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 18)
            newValue.backgroundColor = .white
            newValue.isOpaque = true
        }
    }
    
    @IBOutlet private weak var emailView: ProfileTextEnterView! {
        willSet {
            newValue.titleLabel.text = TextConstants.userProfileEmailSubTitle
            newValue.textField.placeholder = TextConstants.enterYourEmailAddress
            newValue.textField.keyboardType = .emailAddress
            newValue.textField.enablesReturnKeyAutomatically = true
            newValue.textField.returnKeyType = .done
            
            if #available(iOS 10.0, *) {
                newValue.textField.textContentType = .emailAddress
            }
        }
    }
    
    @IBOutlet private weak var continueButton: RoundedInsetsButton! {
        willSet {
            /// Custom type in IB
            newValue.isExclusiveTouch = true
            newValue.setTitle(TextConstants.createStoryPhotosContinue, for: .normal)
            newValue.insets = UIEdgeInsets(top: 5, left: 30, bottom: 5, right: 30)
            
            newValue.setTitleColor(UIColor.white, for: .normal)
            newValue.setTitleColor(UIColor.white.darker(by: 30), for: .highlighted)
            newValue.setBackgroundColor(UIColor.lrTealish, for: .normal)
            newValue.setBackgroundColor(UIColor.lrTealish.darker(by: 30), for: .highlighted)
            newValue.setBackgroundColor(UIColor.lrTealish.withAlphaComponent(0.5), for: .disabled)
            
            newValue.titleLabel?.font = UIFont.TurkcellSaturaDemFont(size: 18)
            newValue.adjustsFontSizeToFitWidth()
        }
    }
}
