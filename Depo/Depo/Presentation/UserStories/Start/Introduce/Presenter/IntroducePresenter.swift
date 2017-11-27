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
        interactor.PrepareModels()
    }
    
    func models(models: [IntroduceModel]) {
        view.setupInitialState(models: models)
    }
    
    //MARK: router
    
    func onStartUsingLifeBox(){
        router.onGoToRegister()
    }
    
    func onLoginButton(){
        router.onGoToLogin()
    }
}
