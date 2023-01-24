//
//  DiscoverInteractorInput.swift
//  Lifebox
//
//  Created by Ozan Salman on 17.11.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

protocol DiscoverInteractorInput {
    var homeCardsLoaded: Bool { get }
    func viewIsReady()
    func needRefresh()
    func trackScreen()
    func trackGiftTapped()
    func updateLocalUserDetail()
    func getPermissionAllowanceInfo(type: PermissionType)
    func updateMobilePaymentPermissionFeedback()
    func changePermissionsAllowed(type: PermissionType, isApproved: Bool)
}
