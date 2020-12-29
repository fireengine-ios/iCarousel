//
//  RegistrationUserInfoModel.swift
//  Depo
//
//  Created by Aleksandr on 6/18/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

struct RegistrationUserInfoModel {
    let mail: String
    let phone: String
    let password: String
    let captchaID: String?
    let captchaAnswer: String?
    
    
    init(mail: String,
         phone: String,
         password: String,
         captchaID: String?,
         captchaAnswer: String?) {
        
        self.mail = mail
        self.phone = phone
        self.password = password
        self.captchaID = captchaID
        self.captchaAnswer = captchaAnswer
    }
}
