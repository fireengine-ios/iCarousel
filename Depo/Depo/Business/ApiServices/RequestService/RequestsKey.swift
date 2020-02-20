//
//  RequestsKey.swift
//  Depo_LifeTech
//
//  Created by Alexander Gurin on 7/1/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

struct LbRequestkeys {
    // MARK: Authificate 
    static let username = "username"
    static let password = "password"
    static let phoneNumber = "phoneNumber"
    static let email = "email"
    static let deviceInfo = "deviceInfo"
    static let on = "on"
    static let off = "off"
    static let language = "language"
    static let eulaId = "eulaId"
    static let sendOtp = "sendOtp"
    static let referenceToken = "referenceToken"
    static let otp = "otp"
    static let processPersonalData = "processPersonalData"
    static let token = "token"
    static let appVersion = "appVersion"
    static let osVersion = "osVersion"
    static let brandType = "brandType"
    static let passwordRuleSetVersion = "passwordRuleSetVersion"
    //
    static let fileName = "Folder-Name"
    static let etkAuth = "etkAuth"
    static let globalPermAuth = "globalPermAuth"
}

struct LbResponseKey {
    static let value = "value"
    static let status = "status"
    static let action = "action"
    static let referenceToken = "referenceToken"
    static let expectedInputLength = "expectedInputLength"
    static let remainingTimeInMinutes = "remainingTimeInMinutes"
    
}
