//
//  PhoneVereficationPhoneVereficationViewInput.swift
//  Depo
//
//  Created by AlexanderP on 14/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol PhoneVereficationViewInput: class, Waiting  {

    func setupInitialState()
    
    func resendButtonShow(show: Bool)
    
    func setupTimer(withRemainingTime remainingTime: Int)
    
    func dropTimer()
    
    func nextButtonEnable(enable: Bool)
    
    func setupTextLengh(lenght: Int)
    
    func setupPhoneLable(with number: String)
    
    func setupButtonsInitialState()
    
    func heighlightInfoTitle()
    
}
