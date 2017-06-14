//
//  TermsAndServicesTermsAndServicesInteractor.swift
//  Depo
//
//  Created by AlexanderP on 09/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class TermsAndServicesInteractor: TermsAndServicesInteractorInput {

    weak var output: TermsAndServicesInteractorOutput!
    var eula = EULA()

    func loadTermsAndUses(){
        weak var weakSelf = self
        eula.requestEulaForLocale(success: { (eula) in
            DispatchQueue.main.async {
                weakSelf?.output.showLoadedTermsAndUses(eula: eula)
            }
        }) { (failString) in
            DispatchQueue.main.async {
                weakSelf?.output.failLoadTermsAndUses(errorString: failString)
            }
        }
    }
    
}
