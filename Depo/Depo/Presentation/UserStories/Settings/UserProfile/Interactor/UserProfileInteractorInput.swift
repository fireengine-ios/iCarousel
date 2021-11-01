//
//  UserProfileUserProfileInteractorInput.swift
//  Depo
//
//  Created by Oleg on 13/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol UserProfileInteractorInput {
    var statusTurkcellUser: Bool { get }
    var userInfo: AccountInfoResponse? { get }
    func viewIsReady()
    func changeTo(name: String, surname: String, email: String, recoveryEmail: String,
                  number: String, birthday: String, address: String, changes: String)
    func updateUserInfo()
    func trackState(_ editState: GAEventLabel, errorType: GADementionValues.errorType?)
    func trackSetSequrityQuestion()
    var secretQuestionsResponse: SecretQuestionsResponse? { get }
    func updateSecretQuestionsResponse(with secretQuestionWithAnswer: SecretQuestionWithAnswer)
    func forceRefreshUserInfo()
    func deleteMyAccount()
}
