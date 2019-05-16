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
    var captchaID: String?
    var captchaAnswer: String?
    
    
    init(mail: String,
         phone: String,
         password: String,
         captchaID: String? = nil,
         captchaAnswer: String? = nil) {
        
        self.mail = mail
        self.phone = phone
        self.password = password
        self.captchaID = captchaID
        self.captchaAnswer = captchaAnswer
    }
}
