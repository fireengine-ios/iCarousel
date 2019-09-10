//
//  TwoFactorChallengeInteractor.swift
//  Depo
//
//  Created by Raman Harhun on 7/17/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

final class TwoFactorChallengeInteractor: PhoneVerificationInteractor {
    
    private var otpParams: TwoFAChallengeParametersResponse
    private let challenge: TwoFAChallengeModel
    private lazy var authService = AuthenticationService()
    private var accountWarningService: AccountWarningService?
    private lazy var eulaService = EulaService()
    
    init(otpParams: TwoFAChallengeParametersResponse, challenge: TwoFAChallengeModel) {
        self.otpParams = otpParams
        self.challenge = challenge
    }
    
    override var expectedInputLength: Int? {
        return otpParams.expectedInputLength
    }
    
    override var remainingTimeInSeconds: Int {
        if let remainingTimeInSeconds = otpParams.remainingTimeInSeconds {
            return remainingTimeInSeconds
        } else {
            return 180
        }
    }
    
    override var phoneNumber: String {
        return challenge.userData
    }
    
    override var textDescription: String {
        guard let status = otpParams.status else {
            return super.textDescription
        }
        
        return challenge.challengeType.getOTPDescription(for: status)
    }
    
    override func resendCode() {
        authenticationService.twoFactorAuthChallenge(token: challenge.token,
                                                     authenticatorId: challenge.userData,
                                                     type: challenge.challengeType.rawValue) { [weak self] response in
            switch response {
            case .success(let parameters):
                self?.otpParams = parameters
                self?.output.resendCodeRequestSucceeded()
                
            case .failed(let error):
                let errorResponse = ErrorResponse.error(error)
                DispatchQueue.main.async {
                    self?.output.resendCodeRequestFailed(with: errorResponse)
                }
                if let serverError = error as? ServerError,
                       serverError.code == TwoFAErrorCodes.tooManyRequests.statusCode {
                        self?.output.verificationFailed(with: error.localizedDescription)
                }
            }
        }
    }
    
    override func verifyCode(code: String) {
        authenticationService.loginViaTwoFactorAuth(token: challenge.token,
                                                    challengeType: challenge.challengeType.rawValue,
                                                    otpCode: code) { response in
                                                        
            DispatchQueue.main.async {
                switch response {
                case .success(_):
                    AccountService().updateBrandType()
                    self.output.verificationSucces()
                case .failed(let error):
                    self.output.verificationFailed(with: error.localizedDescription)
                }
            }
        }
    }
    
    override func updateEmptyPhone(delegate: AccountWarningServiceDelegate) {
        accountWarningService = AccountWarningService(delegate: delegate)
        accountWarningService?.start()
    }
    
    override func stopUpdatePhone() {
        accountWarningService?.stop()
    }
    
    override func updateEmptyEmail() {
        accountWarningService = AccountWarningService()

        let onSuccess: VoidHandler = { [weak self] in
            self?.updateUserLanguage()
        }
        
        accountWarningService?.openEmptyEmail(successHandler: onSuccess)
    }
    
    func updateUserLanguage() {
        authService.updateUserLanguage(Device.supportedLocale) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self?.output.succesLogin()
                case .failed(let error):
                    self?.showPopUp(with: error.localizedDescription)
                }
            }
        }
    }
    
    func checkEULA() {
        eulaService.eulaCheck(success: { [weak self] successResponse in
            DispatchQueue.main.async {
                guard let output = self?.output as? TwoFactorChallengePresenter else {
                    assertionFailure()
                    return
                }
                output.onSuccessEULA()
            }
        }) { [weak self] failResponse in
            DispatchQueue.main.async {
                //TODO: what do we do on other errors?
                ///https://wiki.life.com.by/pages/viewpage.action?pageId=62456128
                if failResponse.description == "EULA_APPROVE_REQUIRED" {
                    guard let output = self?.output as? TwoFactorChallengePresenter else {
                        assertionFailure()
                        return
                    }
                    output.onFailEULA()
                } else {
                    UIApplication.showErrorAlert(message: failResponse.description)
                }
            }
        }
        
    }
}
