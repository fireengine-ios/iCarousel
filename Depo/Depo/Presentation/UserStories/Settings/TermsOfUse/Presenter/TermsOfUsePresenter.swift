//
//  TermsOfUsePresenter.swift
//  Depo
//
//  Created by Konstantin on 8/14/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation


final class TermsOfUsePresenter: BasePresenter  {
   
    weak var view: TermsOfUseViewInput!
    var interactor: TermsOfUseInteractorInput!
    var router: TermsOfUseRouterInput!
    
    
    func viewIsReady() {
        view.showSpinner()
        interactor.getEulaHTML()
    }
}


extension TermsOfUsePresenter: TermsOfUseInteractorOutput {
    func showLoaded(eulaHTML: String) {
        view.hideSpinner()
        view.showLoaded(eulaHTML: eulaHTML)
    }
    
    func failLoadEula(errorString: String) {
        view.hideSpinner()
        view.showAlert(with: errorString)
    }
}


extension TermsOfUsePresenter: TermsOfUseModuleInput {
    
}


extension TermsOfUsePresenter: TermsOfUseViewOutput {
    
}
