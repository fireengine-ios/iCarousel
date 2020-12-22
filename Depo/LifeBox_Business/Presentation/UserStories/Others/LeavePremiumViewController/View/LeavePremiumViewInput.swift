//
//  LeavePremiumViewInput.swift
//  Depo
//
//  Created by Harbros 3 on 11/21/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

protocol LeavePremiumViewInput: class, ActivityIndicator {
    func display(price: String, hideLeaveButton: Bool)
}
