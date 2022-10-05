//
//  SecretAnswerViewswift
//  Depo
//
//  Created by Maxim Soldatov on 9/23/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class SecretAnswerView: UIView, NibInit {
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.textColor = AppColor.label.color
            newValue.font = UIFont.appFont(.light, size: 14.0)
            newValue.text = "  " + TextConstants.userProfileSecretQuestionAnswer + "  "
            newValue.backgroundColor = AppColor.primaryBackground.color
            newValue.isOpaque = true
        }
    }
    
    @IBOutlet weak var answerTextField: QuickDismissPlaceholderTextField! {
        willSet {
            newValue.font = UIFont.appFont(.regular, size: 14.0)
            newValue.textColor = AppColor.blackColor.color
            newValue.borderStyle = .none
            newValue.backgroundColor = AppColor.primaryBackground.color
            newValue.isOpaque = true
            newValue.quickDismissPlaceholder = TextConstants.userProfileSecretQuestionAnswerPlaseholder
            newValue.layer.borderWidth = 1.0
            newValue.layer.borderColor = AppColor.darkTextAndLightGray.cgColor
            newValue.layer.cornerRadius = 8.0
            newValue.setLeftPaddingPoints(10)
            newValue.setRightPaddingPoints(10)
        }
    }
    
    @IBOutlet private weak var errorLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.textOrange
            newValue.font = UIFont.appFont(.regular, size: 12.0)
            newValue.isHidden = true
            newValue.backgroundColor = AppColor.primaryBackground.color
            newValue.isOpaque = true
        }
    }
    
    func showErrorAnimated() {
        guard errorLabel.isHidden else {
            return
        }
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.errorLabel.isHidden = false
            /// https://stackoverflow.com/a/46412621/5893286
            self.layoutIfNeeded()
        }
    }
    
    func hideErrorAnimated() {
        guard !errorLabel.isHidden else {
            return
        }
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.errorLabel.isHidden = true
            /// https://stackoverflow.com/a/46412621/5893286
            self.layoutIfNeeded()
        }
    }
    
    func showErrorAnimated(text: String) {
        errorLabel.text = text
        showErrorAnimated()
    }
    
}

