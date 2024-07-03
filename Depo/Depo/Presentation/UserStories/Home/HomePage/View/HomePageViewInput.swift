//
//  HomePageHomePageViewInput.swift
//  Depo
//
//  Created by AlexanderP on 22/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol HomePageViewInput: AnyObject, CurrentNavController {

    func stopRefresh()
    
    func startSpinner()
        
    func needShowSpotlight(type: SpotlightType)
    
    func showGiftBox()
    
    func hideGiftBox()
    
    func closePermissionPopUp()
    
    func showSnackBarWithMessage(message: String)
    
    func showSegmentControl()
    
    func hideSegmentControl()
    
    func updateCollectionView(with items: [HomeCardResponse])
}
