//
//  SettingsSettingsInteractorOutput.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol SettingsInteractorOutput: AnyObject {
    
    func cellsDataForSettings(isChatbotShown: Bool)
    
    func goToOnboarding()
        
    func profilePhotoUploadSuccessed(image: UIImage?)
    func profilePhotoUploadFailed(error: Error)
    
    func connectToNetworkFailed()
    func asyncOperationStarted()
    func asyncOperationStoped()
    
    func didObtainUserStatus()
    func didFailToObtainUserStatus(errorMessage: String)
    
    func notifSuccess(with notifications: [NotificationServiceResponse])
    func notifFailed(errorResponse: ErrorResponse)
}
