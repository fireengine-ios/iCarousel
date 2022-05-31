//
//  PasswordEnterPopup.swift
//  Depo
//
//  Created by Burak Donat on 3.04.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation
import UIKit
import IQKeyboardManagerSwift

final class PasswordEnterPopup: BasePopUpController, KeyboardHandler, NibInit {

    //MARK: -Properties
    private lazy var accountService = AccountService()
    private lazy var authenticationService = AuthenticationService()
    private lazy var appleGoogleService = AppleGoogleLoginService()
    private lazy var router = RouterVC()
    private var showErrorColorInNewPasswordView = false
    var appleGoogleUser: AppleGoogleUser?
    var disconnectAppleGoogleLogin: Bool?
    
    private let newPasswordView: PasswordView = {
        let view = PasswordView.initFromNib()
        view.titleLabel.text = TextConstants.registrationCellTitlePassword
        view.passwordTextField.placeholder = TextConstants.enterYourNewPassword
        view.passwordTextField.returnKeyType = .next
        return view
    }()
    
    private let repeatPasswordView: PasswordView = {
        let view = PasswordView.initFromNib()
        view.titleLabel.text = TextConstants.registrationCellTitleReEnterPassword
        view.passwordTextField.placeholder = TextConstants.enterYourRepeatPassword
        view.passwordTextField.returnKeyType = .next
        return view
    }()

    //MARK: -IBOutlets
    @IBOutlet private weak var captchaView: CaptchaView!
    @IBOutlet private weak var passwordsStackView: UIStackView! {
        willSet {
            newValue.spacing = 18
            newValue.axis = .vertical
            newValue.alignment = .fill
            newValue.distribution = .fill
            newValue.backgroundColor = AppColor.primaryBackground.color
            newValue.isOpaque = true
            
            newValue.addArrangedSubview(newPasswordView)
            newValue.addArrangedSubview(repeatPasswordView)
        }
    }
    
    @IBOutlet private weak var descriptionLabel: UILabel! {
        willSet {
            newValue.text = localized(.settingsSetNewPassword)
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 20)
            newValue.numberOfLines = 0
            newValue.textColor = AppColor.blackColor.color?.withAlphaComponent(0.9)
        }
    }
    
    @IBOutlet private weak var popupView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 5
        }
    }
    
    @IBOutlet private weak var seperatorView: UIView! {
        willSet {
            newValue.backgroundColor = UIColor.lrTealishTwo
        }
    }
    
    @IBOutlet private weak var okButton: UIButton! {
        willSet {
            newValue.setTitle(TextConstants.ok, for: .normal)
            newValue.setTitleColor(UIColor.lrTealishTwo, for: .normal)
            newValue.setTitleColor(UIColor.lrTealishTwo, for: .highlighted)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 18)
        }
    }
    
    //MARK: -Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = AppColor.popUpBackground.color
        initialViewSetup()
   }
    
    //MARK: -IBActions
    @IBAction func onOkeyButton(_ sender: UIButton) {
        updatePassword()
    }
    
    //MARK: -Helpers
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if touch?.view == view {
            dismiss(animated: true)
        }
    }
    
    private func initialViewSetup() {
        newPasswordView.passwordTextField.delegate = self
        repeatPasswordView.passwordTextField.delegate = self
        captchaView.captchaAnswerTextField.delegate = self
        
        addTapGestureToHideKeyboard()
        IQKeyboardManager.shared.enabledDistanceHandlingClasses.append(PasswordEnterPopup.self)
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    private func showError(_ errorResponse: Error) {
        captchaView.updateCaptcha()
        hideSpinnerIncludeNavigationBar()
        UIApplication.showErrorAlert(message: errorResponse.description) {
            self.dismiss(animated: true)
        }
    }
    
    private func showSuccessPopup() {
        SnackbarManager.shared.show(type: .nonCritical, message: TextConstants.passwordChangedSuccessfully)
        dismiss(animated: true)
    }

    private func showLogoutPopup() {
        let popupVC = PopUpController.with(title: TextConstants.passwordChangedSuccessfullyRelogin,
                                           message: nil,
                                           image: .success,
                                           buttonTitle: TextConstants.ok,
                                           action: { vc in
                                            vc.close {
                                                AppConfigurator.logout()
                                            }
        })
        router.presentViewController(controller: popupVC)
    }
    
    private func actionOnUpdateOnError(_ error: UpdatePasswordErrors) {
        let errorText = error.localizedDescription
        
        switch error {
        case .invalidCaptcha,
             .captchaAnswerIsEmpty:
            captchaView.showErrorAnimated(text: errorText)
            captchaView.captchaAnswerTextField.becomeFirstResponder()
            
        case .invalidNewPassword,
             .newPasswordIsEmpty,
             .passwordInResentHistory,
             .uppercaseMissingInPassword,
             .lowercaseMissingInPassword,
             .passwordIsEmpty,
             .passwordLengthIsBelowLimit,
             .passwordLengthExceeded,
             .passwordSequentialCaharacters,
             .passwordSameCaharacters,
             .numberMissingInPassword:
            showErrorColorInNewPasswordView = true
            
            /// important check to show error only once
            if newPasswordView.passwordTextField.isFirstResponder {
                updateNewPasswordView()
            }
            
            newPasswordView.showTextAnimated(text: errorText)
            newPasswordView.passwordTextField.becomeFirstResponder()
            
        case .invalidOldPassword,
             .oldPasswordIsEmpty:
            break
            
        case .notMatchNewAndRepeatPassword,
             .repeatPasswordIsEmpty:
            repeatPasswordView.showTextAnimated(text: errorText)
            repeatPasswordView.passwordTextField.becomeFirstResponder()
            
        case .special, .unknown,
             .invalidToken,
             .externalAuthTokenRequired,
             .forgetPasswordRequired,
             .emailDomainNotAllowed:
            UIApplication.showErrorAlert(message: errorText)
        }
    }
}

//MARK: -UITextFieldDelegate
extension PasswordEnterPopup: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case newPasswordView.passwordTextField:
            updateNewPasswordView()
        default:
            break
        }
    }
    
    private func updateNewPasswordView() {
        if showErrorColorInNewPasswordView {
            newPasswordView.errorLabel.textColor = ColorConstants.textOrange
            /// we need to show error with color just once
            showErrorColorInNewPasswordView = false
        }
        newPasswordView.showErrorLabelAnimated()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case newPasswordView.passwordTextField:
            newPasswordView.hideErrorLabelAnimated()
        case repeatPasswordView.passwordTextField:
            repeatPasswordView.hideErrorLabelAnimated()
        case captchaView.captchaAnswerTextField:
            captchaView.hideErrorAnimated()
        default:
            assertionFailure()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case newPasswordView.passwordTextField:
            repeatPasswordView.passwordTextField.becomeFirstResponder()
        case repeatPasswordView.passwordTextField:
            captchaView.captchaAnswerTextField.becomeFirstResponder()
        case captchaView.captchaAnswerTextField:
            updatePassword()
        default:
            assertionFailure()
        }
        
        return true
    }
}

//MARK: -Interactor
extension PasswordEnterPopup {
    private func updatePassword() {
        
        guard let newPassword = newPasswordView.passwordTextField.text,
              let repeatPassword = repeatPasswordView.passwordTextField.text,
              let captchaAnswer = captchaView.captchaAnswerTextField.text
        else {
            assertionFailure("all fields should not be nil")
            return
        }
        
        if newPassword.isEmpty {
            actionOnUpdateOnError(.newPasswordIsEmpty)
        } else if repeatPassword.isEmpty {
            actionOnUpdateOnError(.repeatPasswordIsEmpty)
        } else if newPassword != repeatPassword {
            actionOnUpdateOnError(.notMatchNewAndRepeatPassword)
        } else if captchaAnswer.isEmpty {
            actionOnUpdateOnError(.captchaAnswerIsEmpty)
        } else {
            showSpinnerIncludeNavigationBar()
            
            accountService.updatePassword(oldPassword: "",
                                          newPassword: newPassword,
                                          repeatPassword: repeatPassword,
                                          captchaId: captchaView.currentCaptchaUUID,
                                          captchaAnswer: captchaAnswer,
                                          appleGoogleUser: appleGoogleUser) { [weak self] result in
                                            guard let self = self else {
                                                return
                                            }
                                            switch result {
                                            case .success(_):
                                                self.getAccountInfo()
                                            case .failure(let error):
                                                self.actionOnUpdateOnError(error)
                                                self.hideSpinnerIncludeNavigationBar()
                                                self.captchaView.updateCaptcha()
                                            }
            }
            
        }
    }
    
    private func getAccountInfo() {
        accountService.info(success: { [weak self] (response) in
            guard let response = response as? AccountInfoResponse else {
                let error = CustomErrors.serverError("An error occured while getting account info")
                self?.showError(error)
                return
            }
            let login = response.email ?? response.fullPhoneNumber
            self?.loginIfCan(with: login)
        }, fail: { [weak self] error in
            self?.showError(error)
        })
    }
    
    private func loginIfCan(with login: String) {
        guard let newPassword = newPasswordView.passwordTextField.text else {
            assertionFailure("all fields should not be nil")
            return
        }
        
        let user = AuthenticationUser(login: login,
                                      password: newPassword,
                                      rememberMe: true,
                                      attachedCaptcha: nil)
        
        authenticationService.login(user: user, sucess: { [weak self] headers in
            /// on main queue
            if self?.disconnectAppleGoogleLogin == true {
                if let type = self?.appleGoogleUser?.type {
                    self?.removeAppleGoogleLogin(with: type)
                }
            } else {
                self?.showSuccessPopup()
                self?.hideSpinnerIncludeNavigationBar()
            }
            
            }, fail: { [weak self] errorResponse  in
                if errorResponse.description.contains("Captcha required") {
                    self?.showLogoutPopup()
                    self?.hideSpinnerIncludeNavigationBar()
                } else {
                    self?.showError(errorResponse)
                }
            }, twoFactorAuth: { twoFARequered in
                
            /// As a result of the meeting, the logic of showing the screen of two factorial authorization is added only with a direct login and is not used with other authorization methods.
                assertionFailure()
        })
    }
    
    private func removeAppleGoogleLogin(with type: AppleGoogleUserType) {
        appleGoogleService.disconnectAppleGoogleLogin(type: type) { disconnect in
            switch disconnect {
            case .success:
                self.showSuccessPopup()
                self.hideSpinnerIncludeNavigationBar()
                ItemOperationManager.default.appleGoogleLoginDisconnected(type: type)
            case .preconditionFailed, .badRequest:
                UIApplication.showErrorAlert(message: TextConstants.temporaryErrorOccurredTryAgainLater) {
                    self.dismiss(animated: true)
                }
            }
        }
    }
}
