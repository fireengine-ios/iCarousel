//
//  IntroduceIntroducePresenter.swift
//  Depo
//
//  Created by Oleg on 12/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class IntroducePresenter: BasePresenter, IntroduceModuleInput, IntroduceViewOutput {

    weak var view: IntroduceViewInput!
    var interactor: IntroduceInteractorInput!
    var router: IntroduceRouterInput!
    
    override func outputView() -> Waiting? {
        return view as? Waiting
    }

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
        asyncOperationSuccess()
        router.onGoToRegister(with: user)
    }
    
    func passwordLoginRequired(for user: GoogleUser) {
        asyncOperationSuccess()
        view.showGoogleLoginPopup(with: user)
    }
    
    func continueWithGoogleFailed() {
        asyncOperationFail()
        UIApplication.showErrorAlert(message: TextConstants.temporaryErrorOccurredTryAgainLater)
    }
    
    func showTwoFactorAuthViewController(response: TwoFactorAuthErrorResponse) {
        asyncOperationSuccess()
        router.goToTwoFactorAuthViewController(response: response)
    }
    
    func asyncOperationStarted() {
        startAsyncOperation()
    }
    
}
