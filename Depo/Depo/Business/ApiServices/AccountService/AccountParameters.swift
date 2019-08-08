//
//  AccountParameters.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 9/22/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

struct AccountPath {
    static let accountBase = "account/"
    
    static let info = accountBase + "info"
    static let quota = accountBase + "quotaInfo"
    static let usages = accountBase + "usages"
    static let provision = accountBase + "provision"
    static let profilePhoto = accountBase + "profilePhoto"
//    static let storeProducNames = accountBase + "allAccessOffers/APPLE"
    static let offers = accountBase + "offers"
    static let activateOffer = accountBase + "activateOffer"
    static let updateUserName = accountBase + "nameSurname"
    static let updateUserEmail = accountBase + "email"
    static let updatePhoneNumber = accountBase + "updatePhoneNumber"
    static let verifyPhoneNumber = accountBase + "verifyPhoneNumberToUpdate"
    static let securitySettings = "auth/settings"
    static let faceImageAllowed = accountBase + "setting/faceImageAllowed"
    
    static let updateLanguage = accountBase + "language"
    static let languageList = updateLanguage + "/list"
}

class AccontInfo: BaseRequestParametrs {   
    override var patch: URL {
        return URL(string: AccountPath.info, relativeTo: super.patch)!
    }
}

class UserNameParameters: BaseRequestParametrs {
    let userName: String?
    let userSurName: String?
    
    init(userName: String? = nil, userSurName: String? = nil) {
        self.userName = userName
        self.userSurName = userSurName
    }
    
    override var requestParametrs: Any {
        let dict: [String: String] = [AccountJSONConstants.name: userName ?? "", AccountJSONConstants.surname: userSurName ?? ""]
        return dict
    }
    
    override var patch: URL {
        return URL(string: AccountPath.updateUserName, relativeTo: super.patch)!
    }
}

class UserEmailParameters: BaseRequestParametrs {
    let email: String?
    
    init(userEmail: String? = nil) {
        self.email = userEmail
    }
    
    override var requestParametrs: Any {
        let string = email ?? ""
        let data = string.data(using: .utf8)
        return data ?? NSData()
    }
    
    override var patch: URL {
        return URL(string: AccountPath.updateUserEmail, relativeTo: super.patch)!
    }
}

class UserPhoneNumberParameters: BaseRequestParametrs {
    let phoneNumber: String?
    
    init(phoneNumber: String) {
        self.phoneNumber = phoneNumber
    }
    
    override var requestParametrs: Any {
        let dict: [String: String] = [AccountJSONConstants.phoneNumber: phoneNumber ?? ""]
        return dict
    }
    
    override var patch: URL {
        return URL(string: AccountPath.updatePhoneNumber, relativeTo: super.patch)!
    }
}

class VerifyPhoneNumberParameter: BaseRequestParametrs {
    let otp: String?
    let referenceToken: String?
    let processPersonalData: Bool = true
    
    init(otp: String, referenceToken: String) {
        self.otp = otp
        self.referenceToken = referenceToken
    }
    
    override var requestParametrs: Any {
        let dict: [String: String] = [AccountJSONConstants.otp: otp ?? "",
                                      AccountJSONConstants.referenceToken: referenceToken ?? "",
                                      LbRequestkeys.processPersonalData: String(processPersonalData)]
        return dict
    }
    
    override var patch: URL {
        return URL(string: AccountPath.verifyPhoneNumber, relativeTo: super.patch)!
    }
    
}

class LanguageList: BaseRequestParametrs {
    override var patch: URL {
        return URL(string: AccountPath.languageList, relativeTo: super.patch)!
    }
}

class LanguageListChange: BaseRequestParametrs {
    override var patch: URL {
        return URL(string: AccountPath.updateLanguage, relativeTo: super.patch)!
    }
}

class QuotaInfo: BaseRequestParametrs {
    override var patch: URL {
        return URL(string: AccountPath.quota, relativeTo: super.patch)!
    }
}

class UsageParameters: BaseRequestParametrs {
    override var patch: URL {
        return URL(string: AccountPath.usages, relativeTo: super.patch)!
    }
}

class SecuritySettingsInfoParametres: BaseRequestParametrs {
    override var patch: URL {
        return URL(string: AccountPath.securitySettings, relativeTo: super.patch)!
    }
}

class FaceImageAllowedParameters: BaseRequestParametrs {
    var allowed: Bool?
    
    init(allowed: Bool? = false) {
        self.allowed = allowed
    }
    
    override var requestParametrs: Any {
        var string = ""
        if let allowed = allowed {
            string = String(allowed)
        }
        let data = string.data(using: .utf8)
        return data ?? NSData()
    }
    
    override var patch: URL {
        return URL(string: AccountPath.faceImageAllowed, relativeTo: super.patch)!
    }
}

class SecuritySettingsChangeInfoParametres: BaseRequestParametrs {
    let turkcellPasswordAuthEnabled: Bool
    let mobileNetworkAuthEnabled: Bool
    let twoFactorAuthEnabled: Bool

    init(turkcellPasswordAuth: Bool, mobileNetworkAuth: Bool, twoFactorAuth: Bool) {
        turkcellPasswordAuthEnabled = turkcellPasswordAuth
        mobileNetworkAuthEnabled = mobileNetworkAuth
        twoFactorAuthEnabled = twoFactorAuth
    }
    
    override var requestParametrs: Any {
        return ["turkcellPasswordAuthEnabled": turkcellPasswordAuthEnabled,
                "mobileNetworkAuthEnabled": mobileNetworkAuthEnabled,
                "twoFactorAuthEnabled": twoFactorAuthEnabled]
    }
    
    override var patch: URL {
        return URL(string: AccountPath.securitySettings, relativeTo: super.patch)!
    }
}
