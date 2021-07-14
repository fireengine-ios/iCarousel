//
//  UserProfileUserProfileInteractorOutput.swift
//  Depo
//
//  Created by Oleg on 13/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol UserProfileInteractorOutput: AnyObject {
    func configurateUserInfo(userInfo: AccountInfoResponse)
    func startNetworkOperation()
    func stopNetworkOperation()
    func needSendOTP(response: SignUpSuccessResponse, userInfo: AccountInfoResponse)
    func showError(error: String)
    func dataWasUpdated()
}
