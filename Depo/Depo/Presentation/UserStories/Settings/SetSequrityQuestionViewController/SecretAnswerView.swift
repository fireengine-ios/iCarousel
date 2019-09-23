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
    
    @IBOutlet private weak var answerTextField: UITextField! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 18)
            newValue.textColor = UIColor.black
            newValue.borderStyle = .none
            newValue.backgroundColor = .white
            newValue.isOpaque = true
            newValue.placeholder = TextConstants.userProfileSecretQuestionAnswerPlaseholder
        }
    }
    
    @IBOutlet private weak var lineView: UIView! {
        willSet {
            newValue.backgroundColor = ColorConstants.lightText.withAlphaComponent(0.5)
            newValue.isOpaque = true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        answerTextField.delegate = self
    }
    
}


extension SecretAnswerView: UITextFieldDelegate {
    
}
