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
        interactor.trackScreen()
        PushNotificationService.shared.openActionScreen()
    }
    
    func pageChanged(page: Int) {
        interactor.trackScreen(pageNum: page)
    }
    
    // MARK: router
    
    func onStartUsingLifeBox() {
        router.onGoToRegister()
    }
    
    func onLoginButton() {
        router.onGoToLogin()
    }
    
    func onContinueWithGoogle(with user: GoogleUser) {
        interactor.signInWithGoogle(with: user)
    }
}
