//
//  TermsAndPolicyInteractor.swift
//  Depo_LifeTech
//
//  Created by Maxim Soldatov on 6/13/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//



final class TermsAndPolicyInteractor {
    weak var output: TermsAndPolicyInteractorOutput?
}

extension TermsAndPolicyInteractor: TermsAndPolicyInteractorInput {
    
    func getCellData() {
        let termsAndPolicyListItems = [TextConstants.termsOfUseCell, TextConstants.privacyPolicyCell]
        self.output?.cellsDataForTermsAndPolicyList(array: termsAndPolicyListItems)
    }
}

