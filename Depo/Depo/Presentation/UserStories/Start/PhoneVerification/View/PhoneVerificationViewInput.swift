//
//  PhoneVerificationPhoneVerificationViewInput.swift
//  Depo
//
//  Created by AlexanderP on 14/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol PhoneVerificationViewInput: class, Waiting {

    func setupInitialState()
    
    func resendButtonShow(show: Bool)
    
    func setupTimer(withRemainingTime remainingTime: Int)
    
    func dropTimer()
    
    func setupTextLengh(lenght: Int)
    
    func setupPhoneLable(with textDescription: String, number: String)
    
    func setupButtonsInitialState()
        
    func getNavigationController() -> UINavigationController?
    
    func updateEditingState() 
        
    func showError(_ error: String)
    
}
