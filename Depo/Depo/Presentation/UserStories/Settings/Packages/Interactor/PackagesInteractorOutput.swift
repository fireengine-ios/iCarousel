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
    func successedJobExists()
    func successed(offerApples: [OfferApple])
    func successed(tokenForOffer: String)
    func successed(tokenForResend: String)
    func successedVerifyOffer()
    func successed(activeSubscriptions: [SubscriptionPlanBaseResponse])
    func successed(accountTypeString: String)
    func successed(offerApple: OfferApple)
    func failedUsage(with error: ErrorResponse)
    func failedVerifyOffer()
}
