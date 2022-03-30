//
//  IntroduceIntroducePresenter.swift
//  Depo
//
//  Created by Oleg on 12/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class IntroducePresenter: IntroduceModuleInput, IntroduceViewOutput {

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
    
    func goToLogin(with user: GoogleUser) {
        router.onGoToLoginWith(with: user)
    }
}

extension IntroducePresenter: IntroduceInteractorOutput {
    func signUpRequired(for user: GoogleUser) {
        router.onGoToRegister(with: user)
    }
    
    func passwordLoginRequired(for user: GoogleUser) {
        view.showGoogleLoginPopup(with: user)
    }
    
    func goToLoginWithHeaders(with user: GoogleUser, headers: [String : Any]) {
        router.goToLoginWithHeaders(with: user, headers: headers)
    }
    
    func continueWithGoogleFailed() {
        UIApplication.showErrorAlert(message: TextConstants.temporaryErrorOccurredTryAgainLater)
    }
}
