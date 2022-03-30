//
//  RegistrationRegistrationViewOutput.swift
//  Depo
//
//  Created by AlexanderP on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

protocol RegistrationViewOutput {
    
    var isSupportFormPresenting: Bool { get set }

    var eulaText: String? { get }
    
    func viewIsReady()
    
    func prepareCaptcha(_ view: CaptchaView)

    func validatePassword(_ password: String, repassword: String?)
    
    func nextButtonPressed()
    
    func collectedUserInfo(email: String, code: String, phone: String, password: String, repassword: String, captchaID: String?, captchaAnswer: String?, googleToken: String?)
    
    func captchaRequired(required: Bool)
    
    func openSupport()
    
    func openFaqSupport()
    
    func openSubjectDetails(type: SupportFormSubjectTypeProtocol)

    /// Called on phone input text change event
    func phoneNumberChanged(_ code: String, _ phone: String)

    func confirmTermsOfUse(_ confirm: Bool)

    func confirmEtk(_ etk: Bool)

    func openPrivacyPolicyDescriptionController()
}
