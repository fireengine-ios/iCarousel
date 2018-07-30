//
//  TurkcellSecurityInteractorIO.swift
//  Depo
//
//  Created by AlexanderP on 19/12/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol TurkcellSecurityInteractorInput: class {
    func requestTurkcellSecurityState()
    func changeTurkcellSecurity(passcode: Bool, autoLogin: Bool)
    func trackScreen()
    
    var turkcellPasswordOn: Bool { get }
    var turkcellAutoLoginOn: Bool { get }
    var isPasscodeEnabled: Bool { get }
}

protocol TurkcellSecurityInteractorOutput: class {
    func acquiredTurkcellSecurityState(passcode: Bool, autoLogin: Bool)
    func failedToAcquireTurkcellSecurityState()
    func changeTurkcellSecurityFailed(error: ErrorResponse)
}
