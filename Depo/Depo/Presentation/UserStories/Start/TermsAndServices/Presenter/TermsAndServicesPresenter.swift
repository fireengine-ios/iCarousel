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
    private var confirmAgreements = false

    // MARK: IN
    func viewIsReady() {
        interactor.trackScreen()
        startAsyncOperationDisableScreen()
        interactor.loadTermsAndUses()
    }
    
    func startUsing() {
        if confirmAgreements {
            if interactor.cameFromLogin {
                interactor.applyEula()
            } else {
                interactor.signUpUser()
            }
            startAsyncOperationDisableScreen()
        } else {
            view.noConfirmAgreements(errorString: TextConstants.termsAndUseCheckboxErrorText)
        }
    }
    
    func confirmAgreements(_ confirm: Bool) {
        confirmAgreements = confirm
    }
    
    // MARK: OUT
    
    func showLoadedTermsAndUses(eula: String) {
        view.showLoadedTermsAndUses(eula: eula)
        completeAsyncOperationEnableScreen()
    }
    
    func failLoadTermsAndUses(errorString: String) {
        completeAsyncOperationEnableScreen(errorMessage: errorString)
        delegate?.show(errorString: errorString)
        router.closeModule()
    }
    
    func signUpSuccessed() {
        completeAsyncOperationEnableScreen()
        
        if interactor.cameFromLogin {
            router.goToHomePage()
        } else {
            router.goToPhoneVerefication(withSignUpSuccessResponse: interactor.signUpSuccessResponse,
                                         userInfo: interactor.userInfo)
        }
    }
    
    func signupFailed(errorResponce: ErrorResponse) {
        completeAsyncOperationEnableScreen()
        delegate?.show(errorString: errorResponce.description)
        router.closeModule()
    }
    
    func eulaApplied() {
        MenloworksEventsService.shared.onApporveEulaPageClicked()
         completeAsyncOperationEnableScreen()
        //theoreticaly we should add coredata update/append here also
        router.goToAutoSync()
    }
    
    func applyEulaFaild(errorResponce: ErrorResponse) {
        completeAsyncOperationEnableScreen()
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
