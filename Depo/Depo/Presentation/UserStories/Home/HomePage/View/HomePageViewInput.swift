//
//  HomePageHomePageViewInput.swift
//  Depo
//
//  Created by AlexanderP on 22/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol HomePageViewInput: class, CurrentNavController {

    func stopRefresh()
    
    func needPresentPopUp(popUpView: UIViewController)
    
    func needShowSpotlight(type: SpotlightType)
    
}
