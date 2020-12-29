//
//  PurchaseResult.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 9/27/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

enum PurchaseResult {
    case success(String)
    case canceled
    case error(Error)
    case inProgress
}
