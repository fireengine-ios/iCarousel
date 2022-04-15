//
//  AppleGoogleUpdatePasswordPopup.swift
//  Depo
//
//  Created by Burak Donat on 7.04.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation
import UIKit

protocol AppleGoogleUpdatePasswordPopupDelegate: AnyObject {
    func onSignInWithGoogle()
    func onSignInWithApple()
}

final class AppleGoogleUpdatePasswordPopup: BasePopUpController, KeyboardHandler, NibInit {
    
    //MARK: -Properties
    weak var delegate: AppleGoogleUpdatePasswordPopupDelegate?
    
    //MARK: -IBOutlet
    @IBOutlet private weak var descriptionLabel: UILabel! {
        willSet {
            newValue.text = localized(.settingsChangePasswordAppleGoogleWarning)
            newValue.font = UIFont.TurkcellSaturaFont(size: 16)
            newValue.numberOfLines = 0
            newValue.textColor = AppColor.marineTwoAndWhite.color
        }
    }
    
    @IBOutlet private weak var signInWithGoogleButton: RoundedInsetsButton! {
        willSet {
            newValue.setTitle(localized(.connectWithGoogle), for: .normal)
            newValue.setTitleColor(ColorConstants.billoGray, for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 16)
            newValue.adjustsFontSizeToFitWidth()
            newValue.setImage(UIImage(named: "googleLogo"), for: .normal)
            newValue.moveImageLeftTextCenter()
            newValue.backgroundColor = UIColor.white
            newValue.layer.shadowColor = UIColor.black.cgColor
            newValue.layer.shadowRadius = 5
            newValue.layer.shadowOpacity = 0.1
            newValue.layer.shadowOffset = .zero
            newValue.layer.masksToBounds = false
        }
    }
    
    @IBOutlet private weak var signInWithAppleButton: RoundedInsetsButton! {
        willSet {
            newValue.setTitle(localized(.connectWithApple), for: .normal)
            newValue.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            newValue.setTitleColor(AppColor.primaryBackground.color, for: .normal)
            newValue.adjustsFontSizeToFitWidth()
            newValue.setImage(UIImage(named: "appleLogo")?.withRenderingMode(.alwaysTemplate), for: .normal)
            newValue.tintColor = AppColor.primaryBackground.color
            newValue.moveImageLeftTextCenter()
            newValue.backgroundColor = AppColor.blackAndWhite.color
        }
    }
    
    @IBOutlet private weak var popupView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 5
        }
    }
    
    //MARK: -Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = AppColor.popUpBackground.color
    }
    
    //MARK: -IBActions
    @IBAction func onSignInWithGoogle(_ sender: RoundedInsetsButton) {
        delegate?.onSignInWithGoogle()
    }
    
    @IBAction func onSignInWithApple(_ sender: RoundedInsetsButton) {
        delegate?.onSignInWithApple()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if touch?.view == view {
            dismiss(animated: true)
        }
    }
}
