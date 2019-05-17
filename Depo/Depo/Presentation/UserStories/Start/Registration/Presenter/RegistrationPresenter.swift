//
//  RegistrationRegistrationPresenter.swift
//  Depo
//
//  Created by AlexanderP on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//
import UIKit

class RegistrationPresenter: BasePresenter {
    
    weak var view: RegistrationViewInput!
    var interactor: RegistrationInteractorInput!
    var router: RegistrationRouterInput!
    
    var isSupportFormPresenting: Bool = false
    
    // MARK: BasePresenter
    override func outputView() -> Waiting? {
        return view
    }
}

// MARK: - RegistrationViewOutput
extension RegistrationPresenter: RegistrationViewOutput {
    func viewIsReady() {
        interactor.trackScreen()
        startAsyncOperation()
        interactor.checkCaptchaRequerement()
    }
    
    func prepareCaptcha(_ view: CaptchaView) {
        view.delegate = self
    }
    
    func nextButtonPressed() {
        view.collectInputedUserInfo()
    }
    
    func collectedUserInfo(email: String, code: String, phone: String, password: String, repassword: String, captchaID: String?, captchaAnswer: String?) {
        interactor.validateUserInfo(email: email.replacingOccurrences(of: " ", with: ""),
                                    code: code, phone: phone,
                                    password: password, repassword: repassword,
                                    captchaID: captchaID, captchaAnswer: captchaAnswer)
    }
    
    func openSupport() {
        isSupportFormPresenting = true
        router.openSupport()
    }
}

// MARK: - RegistrationInteractorOutput
extension RegistrationPresenter: RegistrationInteractorOutput {
    
    func userValid(_ userInfo: RegistrationUserInfoModel) {
        interactor.signUpUser(userInfo)
    }
    
    func userInvalid(withResult result: [UserValidationResults]) {
        ///sort is needed to priorities the error(empty field is high priority error)
        let sortedResult = result.sorted { _, rignt in
            let mailIsEmpty = (rignt == .mailIsEmpty )
            let phoneIsEmpty = (rignt == .phoneIsEmpty )
            let passwordIsEmpty = (rignt == .passwordIsEmpty )
            let repasswordIsEmpty = (rignt == .passwordIsEmpty )
            let isNeedSwitch = mailIsEmpty || phoneIsEmpty || passwordIsEmpty || repasswordIsEmpty
            return isNeedSwitch
        }
        
        sortedResult.forEach { errorType in
            view.showInfoButton(forType: errorType)
        }
    }
    
    func signUpFailed(errorResponce: ErrorResponse) {
        completeAsyncOperationEnableScreen()
        view.showErrorTitle(withText: errorResponce.description)
        
        if interactor.captchaRequred {
            view.updateCaptcha()
        }
    }
    
    func signUpSuccessed(signUpUserInfo: RegistrationUserInfoModel?, signUpResponse: SignUpSuccessResponse?) {
        completeAsyncOperationEnableScreen()
        router.termsAndServices(with: view, email: signUpUserInfo?.mail ?? "",
                                phoneNumber: signUpUserInfo?.phone ?? "",
                                signUpResponse: signUpResponse,
                                userInfo: signUpUserInfo)
    }
    
    func captchaRequred(requred: Bool) {
        if requred {
            view.setupCaptcha()
        }
        asyncOperationSuccess()
    }
    
    func captchaRequredFailed() {
        asyncOperationSuccess()
    }
    
    func captchaRequredFailed(with message: String) {
        asyncOperationSuccess()
        view.showErrorTitle(withText: message)
    }
    
    func showSupportView() {
        view.showSupportView()
    }
}

extension RegistrationPresenter: CaptchaViewErrorDelegate {
    
    func showCaptchaError(error: Error) {
        
        view.showErrorTitle(withText: error.description)
    }
}
