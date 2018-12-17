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
    
    func homePagePresented()
    
    func needRefresh()
    
    func needCheckQuota()
    
    func trackScreen()

    func updateUserAuthority()
}
