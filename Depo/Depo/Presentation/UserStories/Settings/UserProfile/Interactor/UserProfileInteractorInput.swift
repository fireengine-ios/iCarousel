//
//  UserProfileUserProfileInteractorInput.swift
//  Depo
//
//  Created by Oleg on 13/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol UserProfileInteractorInput {
    var statusTurkcellUser: Bool { get }
    
    func viewIsReady()
    
    func updateBirthday(_ birthday: String)
        
    func changeTo(name: String, surname: String, email: String, number: String)
}
