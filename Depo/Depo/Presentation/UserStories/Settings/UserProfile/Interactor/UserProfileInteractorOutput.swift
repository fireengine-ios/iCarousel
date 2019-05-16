//
//  UserProfileUserProfileInteractorOutput.swift
//  Depo
//
//  Created by Oleg on 13/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol UserProfileInteractorOutput: class {
    
    func configurateUserInfo(userInfo: AccountInfoResponse)
        
    func startNetworkOperation()
    
    func stopNetworkOperation()
    
    func needSendOTP(responce: SignUpSuccessResponse, userInfo: AccountInfoResponse)
    
    func showError(error: String)
    
    func dataWasUpdated()
}
