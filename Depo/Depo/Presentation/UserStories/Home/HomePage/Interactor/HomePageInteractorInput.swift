//
//  HomePageHomePageInteractorInput.swift
//  Depo
//
//  Created by AlexanderP on 22/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol HomePageInteractorInput {
    
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
