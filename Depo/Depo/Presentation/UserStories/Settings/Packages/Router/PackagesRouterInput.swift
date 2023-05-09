//
//  PackagesPackagesRouterInput.swift
//  Depo
//
//  Created by Yaroslav Bondar on 20/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol PackagesRouterInput {
    func openMyStorage(usageStorage: UsageResponse?)
    func openUserProfile(userInfo: AccountInfoResponse, isTurkcellUser: Bool)
    func goToConnectedAccounts()
}
