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
    private lazy var autoSyncRoutingService = AutoSyncRoutingService()
    
    // MARK: IN
    func viewIsReady() {
        interactor.trackScreen()
        if interactor.cameFromLogin {
            view.hideBackButton()
        }
        startAsyncOperationDisableScreen()
        interactor.checkEtk()
    }
    
    func startUsing() {
        if confirmAgreements, interactor.cameFromRegistration {
            router.goToPhoneVerefication(withSignUpSuccessResponse: interactor.signUpSuccessResponse,
                                         userInfo: interactor.userInfo)
        } else if confirmAgreements {
            interactor.applyEula()
        } else {
            view.noConfirmAgreements(errorString: TextConstants.termsAndUseCheckboxErrorText)
        }
    }
    
    func eulaApplied() {
        if interactor.cameFromLogin {
            router.goToAutoSync()
        } else {
            router.goToHomePage()
        }
    }
    
    func applyEulaFaild(errorResponce: ErrorResponse) {
        asyncOperationFail(errorMessage: errorResponce.description)
    }
    
    func confirmAgreements(_ confirm: Bool) {
        confirmAgreements = confirm
    }
    
    func confirmEtk(_ etk: Bool) {
        interactor.etkAuth = etk
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
    // MARK: Utility Methods
    private func openAutoSyncIfNeeded() {
        view.showSpinner()
        
        autoSyncRoutingService.checkNeededOpenAutoSync(success: { [weak self] needToOpenAutoSync in
            self?.view.hideSpinner()
            
            if needToOpenAutoSync {
                self?.router.goToAutoSync()
            }
        }) { [weak self] error in
            self?.view.hideSpinner()
        }
    }
    
    //MARK : BasePresenter
    
    override func outputView() -> Waiting? {
        return view
    }
    
    func setupEtk(isShowEtk: Bool) {
        if isShowEtk {
            view.showEtk()
        }
        interactor.loadTermsAndUses()
    }
}
