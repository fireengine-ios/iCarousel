//
//  UserProfileUserProfileViewInput.swift
//  Depo
//
//  Created by Oleg on 13/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol UserProfileViewInput: class {

    func setupEditState(_ isEdit: Bool)

    func configurateUserInfo(userInfo: AccountInfoResponse)
        
    func getNavigationController() -> UINavigationController?
    
    func getPhoneNumber() -> String
    
    func endSaving()
    
    func updateSetSecretQuestionView(with secrettQuestion: SecretQuestionWithAnswer)
}
