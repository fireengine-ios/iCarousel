//
//  PremiumInteractorInput.swift
//  Depo_LifeTech
//
//  Created by Harbros 3 on 11/16/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

protocol PremiumInteractorInput {
    
    func getAccountType()
    func getFeaturePacks(isAppleProduct: Bool)
    func getPriceInfoFromApple(offer: PackageModelResponse) -> String

    func activate(offer: PackageModelResponse)
    
    func getToken(for: PackageModelResponse)
    func getResendToken(for offer: PackageModelResponse)
    
    func verifyOffer(_ offer: PackageModelResponse, token: String, otp: String)
}
