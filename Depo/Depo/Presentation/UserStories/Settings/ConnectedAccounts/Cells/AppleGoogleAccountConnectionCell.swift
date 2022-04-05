//
//  AppleGoogleAccountConnectionCell.swift
//  Depo
//
//  Created by Burak Donat on 31.03.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import UIKit
import GoogleSignIn
import FirebaseCore

protocol AppleGoogleAccountConnectionCellDelegate: AnyObject {
    func showPasswordRequiredPopup()
    func googleDisconnectFailed()
    func connectGoogleLogin(callback: @escaping (Bool) -> Void)
}

class AppleGoogleAccountConnectionCell: UITableViewCell {
    
    //MARK: -Properties
    private(set) var section: Section?
    private lazy var authenticationService = AuthenticationService()
    private lazy var appleGoogleService = AppleGoogleLoginService()
    weak var delegate: AppleGoogleAccountConnectionCellDelegate?

    //MARK: -IBOutlets
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.numberOfLines = 0
            newValue.text = "ID Eşleştirme"
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 18)
            newValue.textColor = ColorConstants.darkText
        }
    }
    
    @IBOutlet private weak var descriptionLabel: UILabel! {
        willSet {
            newValue.numberOfLines = 0
            newValue.text = "Apple ID veya Google ID nizi hesabınızdan silebilmeniz için önce lifebox platfromunda şifre oluşturmalısınız"
            newValue.font = UIFont.TurkcellSaturaFont(size: 14)
            newValue.textColor = ColorConstants.lightText
        }
    }
    
    @IBOutlet private weak var googleLabel: UILabel! {
        willSet {
            newValue.numberOfLines = 0
            newValue.text = "Google ID eşleştirme"
            newValue.font = UIFont.TurkcellSaturaFont(size: 14)
            newValue.textColor = ColorConstants.darkText
        }
    }
    
    @IBOutlet private weak var appleLabel: UILabel! {
        willSet {
            newValue.numberOfLines = 0
            newValue.text = "Apple ID eşleştirme"
            newValue.font = UIFont.TurkcellSaturaFont(size: 14)
            newValue.textColor = ColorConstants.darkText
        }
    }
    
    @IBOutlet private weak var appleLogo: UIImageView! {
        willSet {
            newValue.image = UIImage(named: "appleLogo")?.withRenderingMode(.alwaysTemplate)
            newValue.tintColor = AppColor.blackColor.color
        }
    }

    @IBOutlet private weak var googleSwitch: UISwitch! {
        willSet {
            newValue.isOn = false
        }
    }
    
    @IBOutlet private weak var appleSwitch: UISwitch! {
        willSet {
            newValue.isUserInteractionEnabled = false
            newValue.isOn = false
        }
    }
    
    //MARK: -Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        getStatus()
    }
    
    //MARK: -IBActions
    @IBAction func googleSwitchToggled(_ sender: UISwitch) {
        if !googleSwitch.isOn {
            disconnectGoogleLogin()
        } else {
            delegate?.connectGoogleLogin(callback: { isSuccess in
                self.googleSwitch.setOn(isSuccess, animated: true)
            })
        }
    }
    
    @IBAction func appleSwitchToggled(_ sender: UISwitch) {
        //TODO -Apple login will be implemented
    }
}

//MARK: -Interactor
extension AppleGoogleAccountConnectionCell {
    private func getStatus() {
        authenticationService.googleLoginStatus { [weak self] bool in
            self?.googleSwitch.setOn(Bool(string: bool) ?? false, animated: true)
        } fail: { value in
            UIApplication.showErrorAlert(message: TextConstants.temporaryErrorOccurredTryAgainLater)
        }
    }
    
    private func  disconnectGoogleLogin() {
        appleGoogleService.disconnectGoogleLogin { disconnect in
            switch disconnect {
            case .success:
                self.googleSwitch.setOn(false, animated: true)
            case .preconditionFailed:
                self.googleSwitch.setOn(true, animated: false)
                self.delegate?.showPasswordRequiredPopup()
            case .badRequest:
                self.googleSwitch.setOn(true, animated: false)
                self.delegate?.googleDisconnectFailed()
            }
        }
    }
}
