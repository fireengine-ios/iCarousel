//
//  PremiumViewInput.swift
//  Depo_LifeTech
//
//  Created by Harbros 3 on 11/16/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

protocol PremiumViewInput: AnyObject, ActivityIndicator {
    func showPaycellProcess(with cpcmOfferId: Int)
    func displayOffers(_ packages: [PackageOffer])
}
