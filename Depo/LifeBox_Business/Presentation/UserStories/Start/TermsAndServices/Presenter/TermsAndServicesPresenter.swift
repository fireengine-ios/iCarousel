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
    private lazy var storageVars: StorageVars = factory.resolve()
    
    // MARK: IN
    func viewIsReady() {
        interactor.trackScreen()
        if interactor.cameFromLogin {
            view.hideBackButton()
        }
        
        interactor.loadTermsAndUses()
    }
    
    func startUsing() {
        if confirmAgreements, interactor.cameFromRegistration {
            router.goToPhoneVerification(withSignUpSuccessResponse: interactor.signUpSuccessResponse,
                                         userInfo: interactor.userInfo)
        } else if confirmAgreements {
            interactor.applyEula()
        } else {
            view.noConfirmAgreements(errorString: TextConstants.termsAndUseCheckboxErrorText)
        }
    }
    
    /// not called for registration. search 'needToOpenAutoSync' in PhoneVerificationPresenter for it
    func eulaApplied() {
       router.goToHomePage()
    }
    
    func applyEulaFailed(errorResponse: ErrorResponse) {
        asyncOperationFail(errorMessage: errorResponse.description)
    }
    
    func confirmAgreements(_ confirm: Bool) {
        confirmAgreements = confirm
    }
    
    func confirmEtk(_ etk: Bool) {
        interactor.etkAuth = etk
        interactor.kvkkAuth = etk
    }
    
    func confirmGlobalPerm(_ globalPerm: Bool) {
        interactor.globalPermAuth = globalPerm
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
    
    func signupFailedCaptchaRequired() {
        delegate?.showCaptcha()
    }
    
    func popUpPressed() {
        view.popNavigationVC()
    }
    
    func openTurkcellAndGroupCompanies() {
        router.goToTurkcellAndGroupCompanies()
    }
    
    func openCommercialEmailMessages() {
        router.goToCommercialEmailMessages()
    }
    
    func openPrivacyPolicyDescriptionController() {
        router.goToPrivacyPolicyDescriptionController()
    }
    
    func openGlobalDataPermissionDetails() {
        router.goToGlobalDataPermissionDetails()
    }

    //MARK : BasePresenter
    
    override func outputView() -> Waiting? {
        return view
    }
}
