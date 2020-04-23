//
//  SettingsSettingsInteractorOutput.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol SettingsInteractorOutput: class {
    
    func cellsDataForSettings(isPermissionShown: Bool)
    
    func goToOnboarding()
    
    func goToContactSync()
    
    func profilePhotoUploadSuccessed(image: UIImage?)
    func profilePhotoUploadFailed(error: Error)
    
    func connectToNetworkFailed()
    func asyncOperationStarted()
    func asyncOperationStoped()
    
    func didObtainUserStatus()
    func didFailToObtainUserStatus(errorMessage: String)
}
