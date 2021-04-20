//
//  SettingsSettingsInteractorOutput.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol SettingsInteractorOutput: class {

    func goToLoginScreen()
    
    func connectToNetworkFailed()
    func asyncOperationStarted()
    func asyncOperationStoped()
    
    func updateStorageUsageDataInfo()
    func didFailToRetrieveUsageData(error: ErrorResponse)
}
