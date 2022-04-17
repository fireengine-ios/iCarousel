//
//  SecurityInfoWarningPopup.swift
//  Depo
//
//  Created by Burak Donat on 12.04.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation
import UIKit

enum SecurityPopupWarningType {
    case email
    case securityQuestion
}

final class SecurityInfoWarningPopup: BasePopUpController, NibInit {
    
    var errorMessage: String?
    var warningType: SecurityPopupWarningType?
    
    @IBOutlet private weak var headerLabel: UILabel! {
        willSet {
            newValue.text = localized(.securityPopupWarningHeader)
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 20)
            newValue.textColor = ColorConstants.textGrayColor
            newValue.numberOfLines = 0
        }
    }
    
    @IBOutlet private weak var bodyLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaFont(size: 18)
            newValue.textColor = ColorConstants.textGrayColor
            newValue.numberOfLines = 0
        }
    }
    
    @IBOutlet private weak var errorLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 16)
            newValue.textColor = ColorConstants.textOrange
            newValue.numberOfLines = 0
        }
    }
    
    @IBOutlet private weak var footerLabel: UILabel! {
        willSet {
            newValue.text = localized(.securityPopupWarningFooter)
            newValue.font = UIFont.TurkcellSaturaFont(size: 18)
            newValue.textColor = ColorConstants.textGrayColor
            newValue.numberOfLines = 0
        }
    }
    
    @IBOutlet private weak var popupView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 5
        }
    }
    
    @IBOutlet private weak var settingsButton: RoundedButton! {
        willSet {
            newValue.setTitle(localized(.securtiyPopupWarningSettingsButton), for: .normal)
            newValue.setTitleColor(AppColor.marineTwoAndTealish.color, for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 18)
            newValue.layer.borderWidth = 1
            newValue.layer.borderColor = AppColor.marineTwoAndTealish.color?.cgColor
        }
    }
    
    @IBOutlet private weak var continueButton: RoundedButton! {
        willSet {
            newValue.setTitle(localized(.securtiyPopupWarningContinueButton), for: .normal)
            newValue.setTitleColor(UIColor.white, for: .normal)
            newValue.backgroundColor = AppColor.marineTwoAndTealish.color
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 18)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.popUpBackground.color
        setup()
    }
    
    @IBAction func onSettingsButton(_ sender: RoundedButton) {
        dismiss(animated: true)
        //todo: go to settings
    }
    
    @IBAction func onContinueButton(_ sender: RoundedButton) {
        dismiss(animated: true)
    }
    
    func setup() {
        errorLabel.text = errorMessage
        
        switch warningType {
        case .email:
            bodyLabel.text = localized(.securityPopupEmailWarning)
        case .securityQuestion:
            bodyLabel.text = localized(.securityPopupSecurityQuestionWarning)
        default:
            break
        }
    }
}
