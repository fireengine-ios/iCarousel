//
//  OTPViewOTPViewController.swift
//  Depo
//
//  Created by Oleg on 12/10/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class OTPViewController: PhoneVereficationViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        phoneCodeLabel.textColor = ColorConstants.textGrayColor
        phoneCodeLabel.textAlignment = .center
        
        codeVereficationField.textColor = ColorConstants.darkText
        codeVereficationField.textAlignment = .center
        
        infoTitle.textColor = ColorConstants.textGrayColor
        infoTitle.textAlignment = .center
        
        
        timerLabel.textColor = ColorConstants.darkText
        timerLabel.textAlignment = .center
        
        mainTitle.textColor = ColorConstants.textGrayColor
        mainTitle.textAlignment = .center
        
        navigationItem.title = TextConstants.phoneVereficationMainTitleText
        
        bacgroundImageView.isHidden = true
    }
    
    override func setupPhoneLable(with number: String) {
        if (Device.isIpad) {
            super.setupPhoneLable(with: number)
        } else {
            mainTitle.text = String(format: TextConstants.otpTitleText, number)
        }
    }
}
