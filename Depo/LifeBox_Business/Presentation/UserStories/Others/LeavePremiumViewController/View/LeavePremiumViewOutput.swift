//
//  LeavePremiumViewOutput.swift
//  Depo
//
//  Created by Harbros 3 on 11/21/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

protocol LeavePremiumViewOutput {
    func onViewDidLoad(with premiumView: LeavePremiumView)
    
    var title: String { get }
    var controllerType: LeavePremiumType { get }
    var accountType: AccountType { get }
}
