//
//  SettingsSettingsInteractorInput.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol SettingsInteractorInput {
    func getCellsData()
    func onLogout()
    func uploadPhoto(withPhoto photo: Data)
    var isPasscodeEmpty: Bool { get }
}
