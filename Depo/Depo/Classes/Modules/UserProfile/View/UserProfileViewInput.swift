//
//  UserProfileUserProfileViewInput.swift
//  Depo
//
//  Created by Oleg on 13/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol UserProfileViewInput: class {

    /**
        @author Oleg
        Setup initial state of the view
    */

    func setupInitialState()
    
    func configurateUserInfo(userInfo: AccountInfoResponse)
    
    func setEditButtonEnable(enable: Bool)
    
    func getNavigationController() -> UINavigationController?
    
}
