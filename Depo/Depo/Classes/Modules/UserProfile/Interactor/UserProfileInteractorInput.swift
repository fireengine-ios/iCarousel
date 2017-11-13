//
//  UserProfileUserProfileInteractorInput.swift
//  Depo
//
//  Created by Oleg on 13/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol UserProfileInteractorInput {
    
    func viewIsReady()
        
    func changeTo(name: String, email: String, number: String)
    
}
