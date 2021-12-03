//
//  UserProfileUserProfileRouterInput.swift
//  Depo
//
//  Created by Oleg on 13/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol UserProfileRouterInput {
    func needSendOTP(response: SignUpSuccessResponse, userInfo: AccountInfoResponse, navigationController: UINavigationController, phoneNumber: String)
    func goToChangePassword()
    func goToSetSecretQuestion(selectedQuestion: SecretQuestionsResponse?, delegate: SetSecurityQuestionViewControllerDelegate)
    func presentDeleteAccountFirstPopUp(confirmed: @escaping DeleteAccountPopUp.ProceedTappedHandler)
    func presentDeleteAccountValidationPopUp(delegate: DeleteAccountValidationPopUpDelegate)
    func presentDeleteAccountFinalPopUp(confirmed: @escaping DeleteAccountPopUp.ProceedTappedHandler)
}
