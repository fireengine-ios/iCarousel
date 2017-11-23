//
//  SettingsSettingsInteractorOutput.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol SettingsInteractorOutput: class {
    
    func cellsDataForSettings(array: [[String]])
    
    func goToOnboarding()
    
    func goToContactSync()
    
    func profilePhotoUploadSuccessed()
    func profilePhotoUploadFailed()
    
    func connectToNetworkFailed()
}
