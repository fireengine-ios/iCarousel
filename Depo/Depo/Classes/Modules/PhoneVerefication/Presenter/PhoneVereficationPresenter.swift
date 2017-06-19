//
//  PhoneVereficationPhoneVereficationPresenter.swift
//  Depo
//
//  Created by AlexanderP on 14/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class PhoneVereficationPresenter: PhoneVereficationModuleInput, PhoneVereficationViewOutput, PhoneVereficationInteractorOutput {

    weak var view: PhoneVereficationViewInput!
    var interactor: PhoneVereficationInteractorInput!
    var router: PhoneVereficationRouterInput!

    func viewIsReady() {
        self.view.setupInitialState()
        self.view.setupTimer()
        self.view.disableNextButton()
    }
    
    func timerFinishedRunning() {
        self.view.disableNextButton()
        self.view.showResendButton()
    }
    
    func resendButtonPressed() {
        self.view.hideResendButton()
        self.view.setupTimer()
    }
    
    func vereficationCodeEntered() {
        self.view.enableNextButton()
    }
    
    func vereficationCodeNotReady() {
        self.view.disableNextButton()
    }
    
    func nextButtonPressed(withVereficationCode vereficationCode: String) {
        //TODO:
        //Verify code
        debugPrint("NEXT with code ", vereficationCode)
        self.router.goToTermAndUses()
        //wait for response from interactor
        //change screen or show error
        //in case of error show Error and disable nextButton
    }
}
