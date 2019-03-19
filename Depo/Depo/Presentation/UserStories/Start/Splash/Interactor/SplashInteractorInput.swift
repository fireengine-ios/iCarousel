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
    func clearAllPreviouslyStoredInfo()
    var isPasscodeEmpty: Bool { get }
    func checkEmptyEmail()
    func updateUserLanguage()
}
