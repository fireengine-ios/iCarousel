//
//  TermsAndServicesTermsAndServicesInteractor.swift
//  Depo
//
//  Created by AlexanderP on 09/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class TermsAndServicesInteractor: TermsAndServicesInteractorInput {

    weak var output: TermsAndServicesInteractorOutput!
    let eula = EULA()
    
    func loadTermsAndUses(){
        eula.requestEulaForLocale(localeString: Util.readLocaleCode(), success: {[weak self] (eula) in
            DispatchQueue.main.async {
                self?.output.showLoadedTermsAndUses(eula: eula)
            }
        }) { [weak self] (failString) in
            DispatchQueue.main.async {
                self?.output.failLoadTermsAndUses(errorString: failString)
            }
        }
    }
    
}
