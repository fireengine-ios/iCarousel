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
    
    func onSignInWithAppleGoogle(with user: AppleGoogleUser) {
        interactor.signInWithAppleGoogle(with: user)
    }
    
    func goToLogin(with user: AppleGoogleUser) {
        router.onGoToLoginWith(with: user)
    }
    
    func goToSignUpWithApple(for user: AppleGoogleUser) {
        signUpRequired(for: user)
    }
}

extension IntroducePresenter: IntroduceInteractorOutput {
    func signUpRequired(for user: AppleGoogleUser) {
        asyncOperationSuccess()
        router.onGoToRegister(with: user)
    }
    
    func passwordLoginRequired(for user: AppleGoogleUser) {
        asyncOperationSuccess()
        view.showGoogleLoginPopup(with: user)
    }
    
    func continueWithAppleGoogleFailed(with error: AppleGoogeLoginError) {
        asyncOperationFail()
        
        let message = error == .emailDomainNotAllowed ? localized(.emailDomainNotAllowed) : TextConstants.temporaryErrorOccurredTryAgainLater
        UIApplication.showErrorAlert(message: message)
    }
    
    func showTwoFactorAuthViewController(response: TwoFactorAuthErrorResponse) {
        asyncOperationSuccess()
        router.goToTwoFactorAuthViewController(response: response)
    }
    
    func asyncOperationStarted() {
        startAsyncOperation()
    }
    
    func signUpRequiredMessage(for user: AppleGoogleUser) {
        asyncOperationSuccess()
        view.signUpRequiredMessage(for: user)
    }
    
}
