//
//  PackagesPackagesInteractorOutput.swift
//  Depo
//
//  Created by Yaroslav Bondar on 20/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol PackagesInteractorOutput: class {
    func successed(allOffers: [PackageModelResponse], group: DispatchGroup)
    
    func successed(tokenForOffer: String)
    func successed(tokenForResend: String)
    
    func successed(accountTypeString: String)
    func successed(usage: UsageResponse)
    func successedGotUserAuthority()
    
    func successedVerifyOffer()

    func failedUsage(with error: ErrorResponse)
    func failed(with errorMessage: String)
    func failedVerifyOffer()
    
    func successedPromocode()
    func failedPromocode(with errorString: String)

    func purchasesRestored(text: String)
    func refreshPackages()
}
