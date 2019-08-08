//
//  UpdatePhoneService.swift
//  Depo
//
//  Created by Raman Harhun
//  Copyright © 2019 LifeTech. All rights reserved.
//

protocol UpdatePhoneServiceDelegate: class {
    
    func successedSilentLogin()
    
    func needToRelogin()
}

final class UpdatePhoneService {
        
    var delegate: UpdatePhoneServiceDelegate?
    
    private var optInController: OptInController?
    private var emptyPhoneController: TextEnterController?

    private lazy var router = RouterVC()
    
    private lazy var accountService = AccountService()
    private lazy var authenticationService = AuthenticationService()
    private lazy var tokenStorage: TokenStorage = factory.resolve()
    
    private var newPhone: String?
    private var referenceToken: String?
    
    init(delegate: UpdatePhoneServiceDelegate? = nil) {
        self.delegate = delegate
    }
    
    //MARK: - Utility Methods(public)
    func start() {
        openEmptyPhone()
    }
    
    func stop(_ handler: VoidHandler? = nil) {
        emptyPhoneController?.dismiss(animated: true, completion: handler)
    }
    
    //MARK: - Utility Methods(private)
    private func openEmptyPhone() {
        tokenStorage.isClearTokens = true
        
        let action: TextEnterHandler = { [weak self] enterText, vc in
            self?.newPhone = enterText
            self?.getToken(for: enterText)
            vc.startLoading()
        }
        
        let emptyPhoneController = TextEnterController.with(title: TextConstants.missingInformation,
                                                            buttonTitle: TextConstants.createStoryPhotosContinue,
                                                            buttonAction: action)
        let navigation = NavigationController(rootViewController: emptyPhoneController)
        
        self.emptyPhoneController = emptyPhoneController
        
        router.presentViewController(controller: navigation)
    }
    
    private func openOptIn(phone: String) {
        let optInController = OptInController.with(phone: phone)
        self.optInController = optInController
        
        emptyPhoneController?.navigationController?.pushViewController(optInController, animated: true)
    }
}

//MARK: Requests
extension UpdatePhoneService {
    
    private func getToken(for phoneNumber: String) {
        let parameters = UserPhoneNumberParameters(phoneNumber: phoneNumber)
        accountService.updateUserPhone(parameters: parameters, success: { [weak self] responce in
            guard let signUpResponce = responce as? SignUpSuccessResponse else {
                return
            }
            DispatchQueue.main.async {
                self?.successed(token: signUpResponce)
            }
        }, fail: { [weak self] error in
            DispatchQueue.main.async {
                self?.failedGetToken(error: error)
            }
        })
    }
    
    private func verifyPhoneNumber(token: String, code: String) {
        let parameters = VerifyPhoneNumberParameter(otp: code, referenceToken: token)
        accountService.verifyPhoneNumber(parameters: parameters, success: { [weak self] baseResponse in
            
            if let response = baseResponse as? ObjectRequestResponse,
                let silentToken = response.responseHeader?[HeaderConstant.silentToken] as? String {
                
                self?.silentLogin(token: silentToken)
            } else {
                DispatchQueue.main.async {
                    self?.delegate?.needToRelogin()
                }
            }
            
        }, fail: { [weak self] errorRespose in
            
            DispatchQueue.main.async { [weak self] in
                self?.failedVerifyPhone(text: TextConstants.phoneVereficationNonValidCodeErrorText)
            }
        })
    }
    
    private func silentLogin(token: String) {
        authenticationService.silentLogin(token: token, success: { [weak self] in
            guard let `self` = self else {
                return
            }
            
            self.accountService.updateBrandType()
            
            self.tokenStorage.isClearTokens = false
            
            DispatchQueue.main.async {
                self.stop {
                    self.delegate?.successedSilentLogin()
                }
                
            }
                
        }, fail: { [weak self] errorResponse in
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.needToRelogin()
            }
        })
    }
}

//MARK: process response
extension UpdatePhoneService {
    
    private func successed(token: SignUpSuccessResponse) {
        referenceToken = token.referenceToken
        
        if let optInController = optInController {
            optInController.stopLoading()
            optInController.setupTimer(withRemainingTime: NumericConstants.vereficationTimerLimit)
            optInController.startEnterCode()
            optInController.hiddenError()
            optInController.hideResendButton()

        } else {
            emptyPhoneController?.stopLoading()
            emptyPhoneController?.close { [weak self] in
                guard let self = self, let newPhone = self.newPhone else {
                    return
                }
                
                self.openOptIn(phone: newPhone)
                self.optInController?.delegate = self
            }

        }
        
    }
    
    private func failedGetToken(error: ErrorResponse) {
        emptyPhoneController?.stopLoading()
        UIApplication.showErrorAlert(message: error.description)
    }
    
    private func failedVerifyPhone(text: String) {
        optInController?.stopLoading()
        optInController?.clearCode()
        optInController?.view.endEditing(true)
        
        if optInController?.increaseNumberOfAttemps() == false {
            optInController?.startEnterCode()
            optInController?.showError(TextConstants.promocodeInvalid)
        }
    }
}

// MARK: - OptInControllerDelegate
extension UpdatePhoneService: OptInControllerDelegate {
    
    func optInResendPressed(_ optInVC: OptInController) {
        self.optInController = optInVC

        optInVC.startLoading()
        
        if let newPhone = newPhone {
            getToken(for: newPhone)
        }
    }
    
    func optInReachedMaxAttempts(_ optInVC: OptInController) {
        optInVC.showResendButton()
        optInVC.dropTimer()
        optInVC.showError(TextConstants.promocodeBlocked)
    }
    
    func optInNavigationTitle() -> String {
        return TextConstants.confirmPhoneOptInNavigarionTitle
    }
    
    func optIn(_ optInVC: OptInController, didEnterCode code: String) {
        self.optInController = optInVC

        optInVC.startLoading()
        
        guard let token = referenceToken else {
            assertionFailure("referenceToken is nil")
            return
        }
        
        verifyPhoneNumber(token: token, code: code)
    }
}
