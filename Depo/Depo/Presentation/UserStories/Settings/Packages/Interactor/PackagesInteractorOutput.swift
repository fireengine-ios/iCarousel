//
//  PackagesPackagesInteractorOutput.swift
//  Depo
//
//  Created by Yaroslav Bondar on 20/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol PackagesInteractorOutput: AnyObject {
    func successed(allOffers: [PackageModelResponse])
 
    func successed(tokenForOffer: String)
    func successed(tokenForResend: String)
    
    func successed(accountTypeString: String)
    func successedGotUserAuthority()
    
    func successedVerifyOffer()

    func failedUsage(with error: ErrorResponse)
    func failed(with errorMessage: String)
    func failedVerifyOffer()
    
    func successedPromocode()
    func failedPromocode(with errorString: String)

    func purchasesRestored(text: String)
    func purchaseCancelled()
    
    func refreshPackages()
    
    func setQuotaInfo(quotoInfo: QuotaInfoResponse)
}
