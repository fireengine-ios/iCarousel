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
            newValue.textColor = UIColor.lrTealish
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 18)
            newValue.text = TextConstants.userProfileSecretQuestionAnswer
            newValue.backgroundColor = .white
            newValue.isOpaque = true
        }
    }
    
    @IBOutlet weak var answerTextField: UITextField! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 18)
            newValue.textColor = UIColor.black
            newValue.borderStyle = .none
            newValue.backgroundColor = .white
            newValue.isOpaque = true
            newValue.placeholder = TextConstants.userProfileSecretQuestionAnswerPlaseholder
        }
    }
    
    @IBOutlet private weak var errorLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.textOrange
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 15)
            newValue.isHidden = true
            newValue.backgroundColor = .white
            newValue.isOpaque = true
        }
    }
    
    @IBOutlet private weak var lineView: UIView! {
        willSet {
            newValue.backgroundColor = ColorConstants.placeholderGrayColor
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

