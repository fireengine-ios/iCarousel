//
//  RegistrationRegistrationInteractorOutput.swift
//  Depo
//
//  Created by AlexanderP on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol RegistrationInteractorOutput: AnyObject {

    func setupEtk(isShowEtk: Bool)
    func userValid(_ userInfo: RegistrationUserInfoModel)
    func userInvalid(withResult result: [UserValidationResults])
    func checkPasswordRuleValid(for result: [UserValidationResults])
    
    func captchaRequired(required: Bool)
    func captchaRequiredFailed()
    func captchaRequiredFailed(with message: String)

    func finishedLoadingTermsOfUse(eula: String)
    func failedToLoadTermsOfUse(errorString: String)
    
    func signUpFailed(errorResponse: Error)
    func signUpSuccessed(signUpUserInfo: RegistrationUserInfoModel?, signUpResponse: SignUpSuccessResponse?)
    
    func showFAQView()
    func showSupportView()
}
