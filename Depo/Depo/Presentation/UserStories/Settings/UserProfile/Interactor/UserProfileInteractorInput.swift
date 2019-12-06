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
    func changeTo(name: String, surname: String, email: String, number: String, birthday: String, address: String)
    func updateUserInfo()
    func trackState(_ editState: GAEventLabel, errorType: GADementionValues.errorType?)
    func trackSetSequrityQuestion()
    var securityQuestionId: Int? { get }
}
