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
        view.showSpiner()
        interactor.getEulaHTML()
    }
}


extension TermsOfUsePresenter: TermsOfUseInteractorOutput {
    func showLoaded(eulaHTML: String) {
        view.hideSpiner()
        view.showLoaded(eulaHTML: eulaHTML)
    }
    
    func failLoadEula(errorString: String) {
        view.hideSpiner()
        view.showAlert(with: errorString)
    }
}


extension TermsOfUsePresenter: TermsOfUseModuleInput {
    
}


extension TermsOfUsePresenter: TermsOfUseViewOutput {
    
}
