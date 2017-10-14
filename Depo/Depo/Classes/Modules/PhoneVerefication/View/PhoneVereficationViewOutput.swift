//
//  PhoneVereficationPhoneVereficationViewOutput.swift
//  Depo
//
//  Created by AlexanderP on 14/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol PhoneVereficationViewOutput {

    /**
        @author AlexanderP
        Notify presenter that view is ready
    */

    func viewIsReady()
    func timerFinishedRunning()
    func resendButtonPressed()
    
    func vereficationCodeEntered(code: String)
    func nextButtonPressed(withVereficationCode vereficationCode: String)
    func vereficationCodeNotReady()
    
}
