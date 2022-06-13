//
//  LoginWithGooglePopup.swift
//  Depo
//
//  Created by Burak Donat on 25.03.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation
import UIKit

protocol LoginWithGooglePopupDelegate: AnyObject {
    func onNextButton()
}

final class LoginWithGooglePopup: BasePopUpController, NibInit {
    
    weak var delegate: LoginWithGooglePopupDelegate?
    var user: AppleGoogleUser?
    
    @IBOutlet private weak var emailLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaBolFont(size: 20)
            newValue.textColor = ColorConstants.textGrayColor
            newValue.numberOfLines = 0
        }
    }
    
    @IBOutlet private weak var descriptionLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 16)
            newValue.textColor = ColorConstants.textGrayColor
            newValue.numberOfLines = 0
        }
    }
    
    @IBOutlet private weak var saveButton: UIButton! {
        willSet {
            newValue.setTitleColor(UIColor.white, for: .normal)
            newValue.setBackgroundColor(UIColor.lrTealish, for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 18)
            newValue.layer.cornerRadius = 25
            newValue.setTitle(TextConstants.nextTitle, for: .normal)
        }
    }
    
    @IBOutlet private weak var popupView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 5
        }
    }
    
    @IBAction func onNextButton(_ sender: Any) {
        delegate?.onNextButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.popUpBackground.color
        let description = user?.type == .google ? localized(.googleUserExistBody) : localized(.appleUserExistBody)
        descriptionLabel.text = String(format: description, user?.email ?? "")
        emailLabel.text = user?.email
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if touch?.view == view {
            dismiss(animated: true)
        }
    }
}
