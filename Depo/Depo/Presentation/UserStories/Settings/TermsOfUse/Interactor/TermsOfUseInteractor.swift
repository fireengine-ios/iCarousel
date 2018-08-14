//
//  TermsOfUseInteractor.swift
//  Depo
//
//  Created by Konstantin on 8/14/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation


final class TermsOfUseInteractor {
    
    weak var output: TermsOfUseInteractorOutput!
    
    private let eulaService = EulaService()
    
}

extension TermsOfUseInteractor: TermsOfUseInteractorInput {
    func getEulaHTML() {
        DispatchQueue.toBackground { [weak self] in
            self?.eulaService.eulaGet(sucess: { [weak self] eula in
                guard let eula = eula as? Eula else {
                    return
                }
                DispatchQueue.toMain {
                    self?.output.showLoaded(eulaHTML: eula.content ?? "")
                }
                }, fail: { [weak self] errorResponse in
                    DispatchQueue.toMain {
                        self?.output.failLoadEula(errorString: errorResponse.description)
                    }
            })
        }
    }
}
