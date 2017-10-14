//
//  CaptchaCaptchaInteractorOutput.swift
//  Depo
//
//  Created by  on 03/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol CaptchaInteractorOutput: class {
    func recivedCaptcha(withType type: CaptchaType, data: Data?)
    func failedResponse(withText text: String)
}
