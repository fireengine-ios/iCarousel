//
//  HomePageHomePageInteractorOutput.swift
//  Depo
//
//  Created by AlexanderP on 22/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol HomePageInteractorOutput: class {
        
    func stopRefresh()
    
    func showPopupAboutPremiumIfNeeded()
    
    func didObtainError(with text: String, isNeedStopRefresh: Bool)
    
    func didObtainHomeCards(_ cards: [HomeCardResponse])
    
    func fillCollectionView(isReloadAll: Bool)
    
    func didObtainQuotaInfo(usagePercentage: Float)
    
    func didObtainAccountInfo(accountInfo: AccountInfoResponse)
    
    func didObtainAccountInfoError(with text: String)

    func didObtainInstaPickStatus(status: InstapickAnalyzesCount)
    
    func showGiftBox()
    
    func hideGiftBox()
    
    func didObtainPermissionAllowance(response: SettingsPermissionsResponse)
    
    func showSuccessMobilePaymentPopup()
}
