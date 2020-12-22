//
//  UserInfoSubViewUserInfoSubViewInteractorOutput.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol UserInfoSubViewInteractorOutput: class {
    func requestsFinished()
    func setUserInfo(userInfo: AccountInfoResponse)
    func setQuotaInfo(quotoInfo: QuotaInfoResponse)
    func failedWith(error: Error)
}
