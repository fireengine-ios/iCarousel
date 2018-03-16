//
//  PhoneEnterCustomizator.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 3/16/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class PhoneEnterCustomizator: NSObject {
    
    @IBOutlet private weak var approveButton: BlueButtonWithWhiteText! {
        didSet {
            approveButton.isExclusiveTouch = true
            //            approveButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 18)
            //            approveButton.setTitleColor(ColorConstants.blueColor, for: .normal)
            //            approveButton.setTitleColor(ColorConstants.blueColor.darker(), for: .highlighted)
            approveButton.setTitle(TextConstants.approve, for: .normal)
        }
    }
    
    @IBOutlet private weak var emailLabel: UILabel! {
        didSet {
            emailLabel.font = UIFont.TurkcellSaturaBolFont(size: 14)
            emailLabel.textColor = ColorConstants.textGrayColor
            emailLabel.text = TextConstants.userProfileEmailSubTitle
        }
    }
    
    @IBOutlet private weak var emailTextField: UnderlineTextField! {
        didSet {
            emailTextField.underlineColor = ColorConstants.grayTabBarButtonsColor
            emailTextField.font = UIFont.TurkcellSaturaBolFont(size: 21)
            emailTextField.textColor = ColorConstants.grayTabBarButtonsColor
        }
    }
    
    @IBOutlet private weak var informationLabel: UILabel! {
        didSet {
            informationLabel.font = UIFont.TurkcellSaturaRegFont(size: 14)
            informationLabel.textColor = ColorConstants.textGrayColor
            informationLabel.text = TextConstants.infomationEmptyEmail
        }
    }
}
