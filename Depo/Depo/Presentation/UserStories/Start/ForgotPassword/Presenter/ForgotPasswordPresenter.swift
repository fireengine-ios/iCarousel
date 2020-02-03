//
//  ForgotPasswordForgotPasswordPresenter.swift
//  Depo
//
//  Created by Oleg on 15/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class ForgotPasswordPresenter: BasePresenter, ForgotPasswordModuleInput, ForgotPasswordViewOutput, ForgotPasswordInteractorOutput {

    weak var view: ForgotPasswordViewInput!
    var interactor: ForgotPasswordInteractorInput!
    var router: ForgotPasswordRouterInput!

    // MARK: input
    func viewIsReady() {
        interactor.trackScreen()
        view.setupVisableTexts()
        checkLanguage()
    }
    
    private func checkLanguage() {
        let langCode = Device.locale
        
        if langCode == "en" || langCode == "tr" {
            view.setupVisableSubTitle()
        }
    }
    
    func onSendPassword(withEmail email: String, enteredCaptcha: String, captchaUDID: String) {
        startAsyncOperationDisableScreen()
        interactor.sendForgotPasswordRequest(with: email, enteredCaptcha: enteredCaptcha, captchaUDID: captchaUDID)
    }
    
    func requestSucceed() {
        completeAsyncOperationEnableScreen()
        router.goToResetPassword()
        //pop back
//        router.popBack()
    }
    
    func requestFailed(withError error: String) {
        
        completeAsyncOperationEnableScreen(errorMessage: error)
        view.showCapcha()
        //TODO: PEstyakov request new captcha here
    }
    
    //MARK : BasePresenter
    
    override func outputView() -> Waiting? {
        return view
    }
    
}
