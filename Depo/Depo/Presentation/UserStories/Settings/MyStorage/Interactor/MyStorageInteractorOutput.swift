//
//  MyStorageInteractorOutput.swift
//  Depo
//
//  Created by Raman Harhun on 11/27/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

protocol MyStorageInteractorOutput: AnyObject {
    
    func successedPackages(accountTypeString: String)
    func successedPackages(allOffers: [PackageModelResponse])
    func successed(tokenForOffer: String)
    func successed(accountInfo: AccountInfoResponse)
    func successed(allOffers: [SubscriptionPlanBaseResponse])
    func failedUsage(with error: ErrorResponse)
    func successed(tokenForResend: String)
    func successedVerifyOffer()
    func failedVerifyOffer()
    func failed(with error: ErrorResponse)
    func failed(with error: String)
    
    func refreshPackages()
    
    func stopActivity()
    func startActivity()
    
    func startPurchase()
    func stopPurchase()
    
    func purchaseCancelled()
    func successedGotUserAuthority()
}
