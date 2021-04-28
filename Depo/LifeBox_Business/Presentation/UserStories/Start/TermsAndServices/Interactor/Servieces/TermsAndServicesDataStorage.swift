//
//  DataStorage.swift
//  Depo
//
//  Created by Aleksandr on 7/11/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

class TermsAndServicesDataStorage {
    var signUpResponse: SignUpSuccessResponse
    
    var signUpUserInfo: RegistrationUserInfoModel
    
    init() {
        signUpResponse = SignUpSuccessResponse(withJSON: nil)
        signUpUserInfo = RegistrationUserInfoModel(mail: "", phone: "", password: "", captchaID: nil, captchaAnswer: nil)
    }
}
