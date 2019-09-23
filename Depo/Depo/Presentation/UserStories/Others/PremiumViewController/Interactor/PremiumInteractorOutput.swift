//
//  PremiumInteractorOutput.swift
//  Depo_LifeTech
//
//  Created by Harbros 3 on 11/16/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

protocol PremiumInteractorOutput: class {
    
    func successed(allFeatures: [PackageModelResponse])
    func successed(accountType: String)
    
    func successed(tokenForOffer: String)
    func successed(tokenForResend: String)
    
    func successedVerifyOffer()
    func successedGotAppleInfo(offer: PackageModelResponse)
    
    func failed(with errorMessage: String)
    func failedResendToken(with errorMessage: String)
    func switchToTextWithoutPrice(isError: Bool)
    func failedVerifyOffer()

    func purchaseFinished()
}
