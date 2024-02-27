//
//  MyStorageViewInput.swift
//  Depo
//
//  Created by Raman Harhun on 11/27/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

protocol MyStorageViewInput: AnyObject, ActivityIndicator {
    func reloadPackages()
    func showRestoreButton()
    
    func reloadData()
    func reloadDataForHighlighted()
    func showInAppPolicy()
    
    func checkIfPremiumBannerValid()
    
    func startPurchase()
    func stopPurchase()
    
    func getIsPaidPackage(isPaidPackage: Bool)
    func getHighlightedPackage(offers: [SubscriptionPlan])
    
    func navigationToController()
}
