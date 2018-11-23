//
//  PackagesPackagesInteractorOutput.swift
//  Depo
//
//  Created by Yaroslav Bondar on 20/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol PackagesInteractorOutput: class {
    func successed(offers: [OfferServiceResponse])
    func successedJobExists(isJobExists: Bool)
    func successed(offerApples: [OfferApple])
    func successed(tokenForOffer: String)
    func successed(tokenForResend: String)
    func successedVerifyOffer()
    func successed(activeSubscriptions: [SubscriptionPlanBaseResponse])
    func successed(accountTypeString: String)
    func successed(offerApple: OfferApple)
    func successed(quotaBytes: Int64)
    func successedGotUserAuthority()
    func failedUsage(with error: ErrorResponse)
    func failed(with errorMessage: String)
    func failedVerifyOffer()
    
    func successedPromocode()
    func failedPromocode(with errorString: String)

    func purchasesRestored(text: String)
}
