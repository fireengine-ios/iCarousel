//
//  MyStorageInteractorOutput.swift
//  Depo
//
//  Created by Raman Harhun on 11/27/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

protocol MyStorageInteractorOutput: class {
    func successed(usage: UsageResponse)
    func successed(accountInfo: AccountInfoResponse)
    
    func successed(allOffers: [SubscriptionPlanBaseResponse])
    func configureAppleOffers()

    func failed(with error: ErrorResponse)
    func failed(with error: String)
}
