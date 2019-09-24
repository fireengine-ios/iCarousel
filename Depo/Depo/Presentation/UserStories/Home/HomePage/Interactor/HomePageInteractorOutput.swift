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
    
    @discardableResult
    func didShowPopupAboutPremium() -> Bool
    
    func didObtainFailCardInfo(errorMessage: String, isNeedStopRefresh: Bool)
    
    func didObtainHomeCards(_ cards: [HomeCardResponse])
    
    func fillCollectionView(isReloadAll: Bool)
    
    func didObtainQuotaInfo(usagePercentage: Float)
    
    func verifyEmailIfNeeded()
    
    func credsCheckUpdateIfNeeded()
        
    func didObtainInstaPickStatus(status: InstapickAnalyzesCount)
}
