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
    
    func getAllCardsForHomePage()
    
    func needPresentPopUp(popUpView: UIViewController)
    
}
