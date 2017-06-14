//
//  TermsAndServicesTermsAndServicesPresenter.swift
//  Depo
//
//  Created by AlexanderP on 09/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class TermsAndServicesPresenter: TermsAndServicesModuleInput, TermsAndServicesViewOutput, TermsAndServicesInteractorOutput {

    weak var view: TermsAndServicesViewInput!
    var interactor: TermsAndServicesInteractorInput!
    var router: TermsAndServicesRouterInput!

    // MARK: IN
    func viewIsReady() {
        self.interactor.loadTermsAndUses()
    }
    
    func termsApplied(){
        self.router.goToRegister()
    }
    
    // MARK: OUT
    
    func showLoadedTermsAndUses(eula: Eula){
        self.view.showLoadedTermsAndUses(eula: eula)
    }
    
    func failLoadTermsAndUses(errorString:String){
        self.view.failLoadTermsAndUses(errorString: errorString)
    }
}
