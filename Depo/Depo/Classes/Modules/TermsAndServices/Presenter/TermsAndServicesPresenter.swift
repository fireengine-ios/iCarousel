//
//  TermsAndServicesTermsAndServicesPresenter.swift
//  Depo
//
//  Created by AlexanderP on 09/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class TermsAndServicesPresenter: BasePresenter, TermsAndServicesModuleInput, TermsAndServicesViewOutput, TermsAndServicesInteractorOutput {

    weak var view: TermsAndServicesViewInput!
    var interactor: TermsAndServicesInteractorInput!
    var router: TermsAndServicesRouterInput!
    
    weak var delegate: RegistrationViewDelegate?

    // MARK: IN
    func viewIsReady() {
        startAsyncOperationDisableScreen()
        interactor.loadTermsAndUses()
    }
    
    func termsApplied(){
        if interactor.cameFromLogin {
            interactor.applyEula()
        } else {
            interactor.signUpUser()
        }
        startAsyncOperationDisableScreen()
    }
    
    // MARK: OUT
    
    func showLoadedTermsAndUses(eula: String){
        view.showLoadedTermsAndUses(eula: eula)
        compliteAsyncOperationEnableScreen()
    }
    
    func failLoadTermsAndUses(errorString:String){
        compliteAsyncOperationEnableScreen(errorMessage: errorString)
        delegate?.show(errorString: errorString)
        router.closeModule()
    }
    
    func signUpSuccessed() {
        compliteAsyncOperationEnableScreen()
        
        if interactor.cameFromLogin {
            router.goToHomePage()
        } else {
            router.goToPhoneVerefication(withSignUpSuccessResponse: interactor.signUpSuccessResponse,
                                         userInfo: interactor.userInfo)
        }
    }
    
    func signupFailed(errorResponce: ErrorResponse) {
        compliteAsyncOperationEnableScreen()
        delegate?.show(errorString: errorResponce.description)
        router.closeModule()
    }
    
    func eulaApplied(){
         compliteAsyncOperationEnableScreen()
        router.goToHomePage()
    }
    
    func applyEulaFaild(errorResponce: ErrorResponse) {
        compliteAsyncOperationEnableScreen()
        delegate?.show(errorString: errorResponce.description)
        router.closeModule()
    }
    
    func popUpPressed() {
        view.popNavigationVC()
    }
    
    //MARK : BasePresenter
    
    override func outputView() -> Waiting? {
        return view
    }
}
