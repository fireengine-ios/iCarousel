//
//  PremiumViewOutput.swift
//  Depo_LifeTech
//
//  Created by Harbros 3 on 11/16/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

protocol PremiumViewOutput {
    func onViewDidLoad(with premiumView: BecomePremiumView)
    
    var title: String { get }
    var headerTitle: String { get }
    var accountType: AccountType { get }
}
