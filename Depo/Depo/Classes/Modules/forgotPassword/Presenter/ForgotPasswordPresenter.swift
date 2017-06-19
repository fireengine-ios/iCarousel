//
//  ForgotPasswordForgotPasswordPresenter.swift
//  Depo
//
//  Created by Oleg on 15/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class ForgotPasswordPresenter: ForgotPasswordModuleInput, ForgotPasswordViewOutput, ForgotPasswordInteractorOutput {

    weak var view: ForgotPasswordViewInput!
    var interactor: ForgotPasswordInteractorInput!
    var router: ForgotPasswordRouterInput!

    //MARK: input
    func viewIsReady() {

    }
    
    func onSendPassword(){
        
    }
}
