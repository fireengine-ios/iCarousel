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
    
    func tapEditButton()
    func tapReadyButton(name: String, surname: String, email: String, recoveryEmail: String,
                        number: String, birthday: String, address: String, changes: String)
    func tapChangePasswordButton()
    func tapChangeSecretQuestionButton()
    
    func isTurkcellUser() -> Bool
    
    func showError(error: String)
}
