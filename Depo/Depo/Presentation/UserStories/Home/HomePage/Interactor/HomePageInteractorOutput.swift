//
//  HomePageHomePageInteractorOutput.swift
//  Depo
//
//  Created by AlexanderP on 22/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol HomePageInteractorOutput: AnyObject {
        
    func stopRefresh()
    
    func didObtainError(with text: String, isNeedStopRefresh: Bool)
    
    func didObtainHomeCards(_ cards: [HomeCardResponse])
    
    func fillCollectionView(isReloadAll: Bool)
    
    func fillCollectionViewForHighlighted(isPaidPackage: Bool, offers: SubscriptionPlan?, packageIndex: Int)
    
    func didObtainQuotaInfo(usagePercentage: Float)
    
    func didObtainAccountInfo(accountInfo: AccountInfoResponse)
    
    func didObtainAccountInfoError(with text: String)

    func didObtainInstaPickStatus(status: InstapickAnalyzesCount)
    
    func showGiftBox()
    
    func hideGiftBox()
    
    func didObtainPermissionAllowance(response: SettingsPermissionsResponse)
    
    func didObtainHomeCardsBestScene(_ bestSceneCard: HomeCardResponse, imageUrls: [String], createdDate: [Int], groupId: [Int])
        
    func showSuccessMobilePaymentPopup()
    
    func showSpinner()
    
    func hideSpinner()
    
    func showSnackBarWith(message: String)
    
    func publicShareSaveSuccess()
    
    func publicShareSaveFail(message: String)
    
    func publicShareSaveStorageFail()
    
    func showSegmentControl()
    
    func hideSegmentControl()
}
