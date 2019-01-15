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
    
    func needPresentPopUp(popUpView: UIViewController)
    
    func didShowPopupAboutPremium()
    
    func didObtainFailCardInfo(errorMessage: String, isNeedStopRefresh: Bool)
    
    func didObtainHomeCards(_ cards: [HomeCardResponse])
    
    func fillCollectionView(isReloadAll: Bool)
    
    func didOpenExpand()
    
    func didObtainInstaPickStatus(status: InstapickAnalyzesCount)
}
