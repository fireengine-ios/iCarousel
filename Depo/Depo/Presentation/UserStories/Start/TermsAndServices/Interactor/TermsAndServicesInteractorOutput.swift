//
//  TermsAndServicesTermsAndServicesInteractorOutput.swift
//  Depo
//
//  Created by AlexanderP on 09/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol TermsAndServicesInteractorOutput: class {
    func showLoadedTermsAndUses(eula: String)
    func failLoadTermsAndUses(errorString: String)
    func popUpPressed()
    func signupFailedCaptchaRequired()
    func setupEtk(isShowEtk: Bool)
    func setupGlobalPerm(isShowGlobalPerm: Bool)
    func applyEulaFaild(errorResponce: ErrorResponse)
    func eulaApplied()
}
