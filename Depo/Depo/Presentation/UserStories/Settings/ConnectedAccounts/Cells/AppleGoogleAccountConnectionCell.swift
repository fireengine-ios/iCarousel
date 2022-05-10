//
//  AppleGoogleAccountConnectionCell.swift
//  Depo
//
//  Created by Burak Donat on 31.03.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import UIKit
import AuthenticationServices

protocol AppleGoogleAccountConnectionCellDelegate: AnyObject {
    func showPasswordRequiredPopup(type: AppleGoogleUserType)
    func appleGoogleDisconnectFailed(type: AppleGoogleUserType)
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
            newValue.text = localized(.settingsAppleGoogleTitle)
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 18)
            newValue.textColor = ColorConstants.darkText
        }
    }
    
    @IBOutlet private weak var googleLabel: UILabel! {
        willSet {
            newValue.numberOfLines = 0
            newValue.text = localized(.settingsGoogleMatch)
            newValue.font = UIFont.TurkcellSaturaFont(size: 14)
            newValue.textColor = ColorConstants.darkText
        }
    }
    
    @IBOutlet private weak var appleLabel: UILabel! {
        willSet {
            newValue.numberOfLines = 0
            newValue.text = localized(.settingsAppleMatch)
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
            newValue.isOn = false
        }
    }
    
    //MARK: -Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        getGoogleStatus()
        getAppleStatus()
        ItemOperationManager.default.startUpdateView(view: self)
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
        if !appleSwitch.isOn {
            disconnectAppleLogin()
        } else {
            startConnectingAppleLogin()
        }
    }
    
    private func startConnectingAppleLogin() {
        if #available(iOS 13.0, *) {
            let controller = appleGoogleService.getAppleAuthorizationController()
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }
    
    private func connectAppleLogin(with user: AppleGoogleUser) {
        appleGoogleService.connectAppleGoogleLogin(with: user) { result in
            switch result {
            case .success:
                self.appleSwitch.setOn(true, animated: true)
            case .preconditionFailed(let error):
                self.appleSwitch.setOn(false, animated: true)
                DispatchQueue.toMain {
                    UIApplication.showErrorAlert(message: error?.errorMessage ?? TextConstants.temporaryErrorOccurredTryAgainLater)
                }
            case .badRequest(let error):
                self.appleSwitch.setOn(false, animated: true)
                DispatchQueue.toMain {
                    UIApplication.showErrorAlert(message: error?.errorMessage ?? TextConstants.temporaryErrorOccurredTryAgainLater)
                }
            }
        }
    }
}

//MARK: -Interactor
extension AppleGoogleAccountConnectionCell {
    private func getGoogleStatus() {
        authenticationService.googleLoginStatus { [weak self] bool in
            self?.googleSwitch.setOn(Bool(string: bool) ?? false, animated: true)
        } fail: { value in
            UIApplication.showErrorAlert(message: TextConstants.temporaryErrorOccurredTryAgainLater)
        }
    }
    
    private func getAppleStatus() {
        authenticationService.appleLoginStatus { [weak self] bool in
            self?.appleSwitch.setOn(Bool(string: bool) ?? false, animated: true)
        } fail: { value in
            UIApplication.showErrorAlert(message: TextConstants.temporaryErrorOccurredTryAgainLater)
        }
    }
    
    private func  disconnectGoogleLogin() {
        appleGoogleService.disconnectAppleGoogleLogin(type: .google) { disconnect in
            switch disconnect {
            case .success:
                self.googleSwitch.setOn(false, animated: true)
            case .preconditionFailed(let error):
                self.googleSwitch.setOn(true, animated: false)
                if error == .passwordRequired {
                    self.delegate?.showPasswordRequiredPopup(type: .google)
                }
            case .badRequest:
                self.googleSwitch.setOn(true, animated: false)
                self.delegate?.appleGoogleDisconnectFailed(type: .google)
            }
        }
    }
    
    private func  disconnectAppleLogin() {
        appleGoogleService.disconnectAppleGoogleLogin(type: .apple) { disconnect in
            switch disconnect {
            case .success:
                self.appleSwitch.setOn(false, animated: true)
            case .preconditionFailed(let error):
                self.appleSwitch.setOn(true, animated: false)
                if error == .passwordRequired {
                    self.delegate?.showPasswordRequiredPopup(type: .apple)
                }
            case .badRequest:
                self.appleSwitch.setOn(true, animated: false)
                self.delegate?.appleGoogleDisconnectFailed(type: .apple)
            }
        }
    }
}

extension AppleGoogleAccountConnectionCell: ItemOperationManagerViewProtocol {
    func isEqual(object: ItemOperationManagerViewProtocol) -> Bool {
        return self === object
    }
    
    func appleGoogleLoginDisconnected(type: AppleGoogleUserType) {
        type == .google ? googleSwitch.setOn(false, animated: true) : appleSwitch.setOn(false, animated: true)
    }
}

@available(iOS 13.0, *)
extension AppleGoogleAccountConnectionCell: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credentials = authorization.credential as? ASAuthorizationAppleIDCredential {
            appleGoogleService.getAppleCredentials(with: credentials) { user in
                guard let user = user else { return }
                let appleUser = AppleGoogleUser(idToken: user.idToken, email: user.email, type: .apple)
                connectAppleLogin(with: appleUser)
            } fail: { error in
                debugLog(error)
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        debugLog("Apple auth didCompleteWithError: \(error.localizedDescription)")
    }
}

@available(iOS 13.0, *)
extension AppleGoogleAccountConnectionCell: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return contentView.window!
    }
}
