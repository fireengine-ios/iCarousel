import UIKit

final class EmailEnterDesigner: NSObject {
    @IBOutlet private weak var infoLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.pleaseEnterYourMissingAccountInformation
            newValue.textColor = AppColor.blackColor.color
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 18)
            newValue.backgroundColor = AppColor.primaryBackground.color
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
            newValue.textField.textContentType = .emailAddress
        }
    }
    
    @IBOutlet private weak var continueButton: RoundedInsetsButton! {
        willSet {
            /// Custom type in IB
            newValue.isExclusiveTouch = true
            newValue.setTitle(TextConstants.createStoryPhotosContinue, for: .normal)
            newValue.insets = UIEdgeInsets(top: 5, left: 30, bottom: 5, right: 30)
            
            newValue.setTitleColor(UIColor.white, for: .normal)
            newValue.setBackgroundColor(AppColor.darkBlueColor.color, for: .normal)
            
            newValue.titleLabel?.font = UIFont.TurkcellSaturaDemFont(size: 18)
            newValue.adjustsFontSizeToFitWidth()
        }
    }
}
