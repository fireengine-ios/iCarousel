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
        interactor.checkEtk(for: "+380962868642")
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
    
    func signupFailedCaptchaRequired() {
        delegate?.showCaptcha()
    }
    
    func eulaApplied() {
        MenloworksEventsService.shared.onApporveEulaPageClicked()
         completeAsyncOperationEnableScreen()
        //theoreticaly we should add coredata update/append here also
        if interactor.cameFromLogin, storageVars.autoSyncSet {
            router.goToHomePage()
        } else {
            openAutoSyncIfNeeded()
        }
    }
    
    func applyEulaFaild(errorResponce: ErrorResponse) {
        completeAsyncOperationEnableScreen()
        delegate?.show(errorString: errorResponce.description)
        router.closeModule()
    }
    
    func popUpPressed() {
        view.popNavigationVC()
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
