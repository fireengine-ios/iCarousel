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
            self?.eulaService.eulaGet { [weak self] response in
                switch response {
                case .success(let text):
                    guard let content = text.content else {
                        assertionFailure()
                        return
                    }
                    DispatchQueue.toMain {
                        self?.output.showLoaded(eulaHTML: content)
                    }
                    
                case .failed(let error):
                    self?.output.failLoadEula(errorString: error.description)
                    assertionFailure("Failed move to Terms Description ")
                }
            }
        }
    }
}
