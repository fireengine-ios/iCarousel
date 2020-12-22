//
//  LeavePremiumInteractorInput.swift
//  Depo
//
//  Created by Harbros 3 on 11/21/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

protocol LeavePremiumInteractorInput: class {
    func getAccountType(with accountType: String, offers: [Any]) -> AccountType?
    
    func trackScreen(screenType: LeavePremiumType)
}
