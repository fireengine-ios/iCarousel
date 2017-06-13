//
//  IntroduceIntroducePresenter.swift
//  Depo
//
//  Created by Oleg on 12/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class IntroducePresenter: IntroduceModuleInput, IntroduceViewOutput, IntroduceInteractorOutput {

    weak var view: IntroduceViewInput!
    var interactor: IntroduceInteractorInput!
    var router: IntroduceRouterInput!

    func viewIsReady() {
        self.interactor.PrepareModels()
    }
    
    func models(models: [IntroduceModel]) {
        self.view.setupInitialState(models: models)
    }
    
    //MARK: router
    
    func onStartUsingLifeBox(){
        self.router.onGoToRegister()
    }
    
    func onLoginButton(){
        self.router.onGoToLogin()
    }
}
