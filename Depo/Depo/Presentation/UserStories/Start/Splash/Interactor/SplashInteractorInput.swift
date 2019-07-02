//
//  SplashSplashInteractorInput.swift
//  Depo
//
//  Created by Oleg on 10/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol SplashInteractorInput {
    func startLoginInBackground()
    func checkEULA()
    var isPasscodeEmpty: Bool { get }
    func checkEmptyEmail()
    func updateUserLanguage()
}
