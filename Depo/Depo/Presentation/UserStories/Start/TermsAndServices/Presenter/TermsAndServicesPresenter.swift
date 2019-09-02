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
        interactor.checkEtkAndGlobalPermissions()
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
    
    func eulaApplied() {
        if interactor.cameFromLogin, !interactor.isLoggedIn {
            router.goToAutoSync()
        } else {
            router.goToHomePage()
        }
    }
    
    func applyEulaFailed(errorResponse: ErrorResponse) {
        asyncOperationFail(errorMessage: errorResponse.description)
    }
    
    func confirmAgreements(_ confirm: Bool) {
        confirmAgreements = confirm
    }
    
    func confirmEtk(_ etk: Bool) {
        interactor.etkAuth = etk
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
    
    func setupGlobalPerm(isShowGlobalPerm: Bool) {
        if isShowGlobalPerm {
//            TODO: add logic with UI
//            view.showGlobalPermission()
        }
        interactor.loadTermsAndUses()
    }
    
    func setupEtkAndGlobalPermissions(isShowEtk: Bool, isShowGlobalPerm: Bool) {
        if isShowEtk {
            view.showEtk()
        }
        if isShowGlobalPerm {
            view.showGlobalPermissions()
        }
        interactor.loadTermsAndUses()
    }
}
