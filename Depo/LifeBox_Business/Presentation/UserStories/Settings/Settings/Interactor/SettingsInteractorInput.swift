//
//  SettingsSettingsInteractorInput.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol SettingsInteractorInput {
    
    var userInfoResponse: AccountInfoResponse? { get }
    var isPasscodeEmpty: Bool { get }
    var isTurkcellUser: Bool { get }
    var isEmptyMail: Bool { get }
    
    func getCellsData()
    func onLogout()
    func uploadPhoto(withPhoto photo: Data)
    func checkConnectedToNetwork()
    
    func updateUserInfo(mail: String)
    
    func trackScreen()
    func trackPhotoEdit()
    
    func getUserInfo()
}
