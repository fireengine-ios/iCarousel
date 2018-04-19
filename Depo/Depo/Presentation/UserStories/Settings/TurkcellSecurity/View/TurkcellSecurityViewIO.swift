//
//  TurkcellSecurityViewIO.swift
//  Depo
//
//  Created by AlexanderP on 19/12/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol TurkcellSecurityViewInput: class {
    func setupSecuritySettings(passcode: Bool, autoLogin: Bool)
}

protocol TurkcellSecurityViewOutput: class {
    func viewIsReady()
    func securityChanged(passcode: Bool, autoLogin: Bool, title: String)
}
