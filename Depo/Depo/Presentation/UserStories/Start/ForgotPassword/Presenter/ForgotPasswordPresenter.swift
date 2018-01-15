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

    //MARK: input
    func viewIsReady() {
        checkLanguadge()
    }
    
    private func checkLanguadge() {
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
        compliteAsyncOperationEnableScreen()
        router.goToResetPassword()
        //pop back
//        router.popBack()
    }
    
    func requestFailed(withError error: String) {
        
        compliteAsyncOperationEnableScreen(errorMessage: error)
        //TODO: PEstyakov request new captcha here
    }
    
    //MARK : BasePresenter
    
    override func outputView() -> Waiting? {
        return view
    }
    
}
