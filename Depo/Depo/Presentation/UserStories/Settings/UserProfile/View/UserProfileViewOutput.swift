//
//  UserProfileUserProfileViewOutput.swift
//  Depo
//
//  Created by Oleg on 13/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol UserProfileViewOutput {

    /**
        @author Oleg
        Notify presenter that view is ready
    */

    func viewIsReady()
    func viewDidAppear()

    func tapEditButton()
    func tapReadyButton(name: String, surname: String, email: String, recoveryEmail: String,
                        number: String, birthday: String, address: String, changes: String)
    func tapChangePasswordButton()
    func tapChangeSecretQuestionButton()
    func tapDeleteMyAccount()
    
    func isTurkcellUser() -> Bool

    func emailVerificationCompleted()

    func showError(error: String)
}
