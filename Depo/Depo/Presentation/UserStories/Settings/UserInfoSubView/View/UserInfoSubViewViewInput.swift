//
//  UserInfoSubViewUserInfoSubViewViewInput.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol UserInfoSubViewViewInput: class {

    func setupInitialState()
    
    func setUserInfo(userInfo: AccountInfoResponse)
    
    func setQuotaInfo(quotoInfo: QuotaInfoResponse)
    
}
