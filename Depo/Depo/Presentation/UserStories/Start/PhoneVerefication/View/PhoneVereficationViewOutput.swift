//
//  PhoneVereficationPhoneVereficationViewOutput.swift
//  Depo
//
//  Created by AlexanderP on 14/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol PhoneVereficationViewOutput {
    func viewIsReady()
    func timerFinishedRunning()
    func resendButtonPressed()
    func vereficationCodeEntered(code: String)
    func vereficationCodeNotReady()
}
