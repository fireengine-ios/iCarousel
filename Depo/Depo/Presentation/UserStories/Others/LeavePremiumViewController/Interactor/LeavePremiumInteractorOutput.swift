//
//  LeavePremiumInteractorOutput.swift
//  Depo
//
//  Created by Harbros 3 on 11/21/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

protocol LeavePremiumInteractorOutput: class {
    func didLoadAccountType(accountTypeString: String)
    func didLoadActiveSubscriptions(_ offers: [SubscriptionPlanBaseResponse])
    func didLoadInfoFromApple()
    
    func didErrorMessage(with text: String)
}
