//
//  PhoneVerificationPhoneVerificationViewOutput.swift
//  Depo
//
//  Created by AlexanderP on 14/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol PhoneVerificationViewOutput {
    var currentSecurityCode: String { get }
    func viewIsReady()
    func timerFinishedRunning(with isShowMessageWithDropTimer: Bool)
    func resendButtonPressed()
    func verificationCodeEntered()
    func verificationCodeNotReady()
    func currentSecurityCodeChanged(with newNumeric: String)
    func currentSecurityCodeRemoveCharacter()
    func clearCurrentSecurityCode()
}
