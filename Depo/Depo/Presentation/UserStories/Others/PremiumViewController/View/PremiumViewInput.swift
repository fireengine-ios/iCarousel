//
//  PremiumViewInput.swift
//  Depo_LifeTech
//
//  Created by Harbros 3 on 11/16/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

protocol PremiumViewInput: class, ActivityIndicator {
    func displayFeatureInfo(price: String?, description: String, isNeedPolicy: Bool)
    func showPaycellProcess(with cpcmOfferId: Int)
}
