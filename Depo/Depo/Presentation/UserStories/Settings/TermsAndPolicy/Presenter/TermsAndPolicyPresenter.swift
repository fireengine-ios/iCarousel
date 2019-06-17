//
//  TermsAndPolicyPresenter.swift
//  Depo_LifeTech
//
//  Created by Maxim Soldatov on 6/13/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

final class TermsAndPolicyPresenter: BasePresenter {
    weak var view: TermsAndPolicyViewInput!
    var interactor: TermsAndPolicyInteractorInput!
    var router: TermsAndPolicyRouterInput!
}

extension TermsAndPolicyPresenter: TermsAndPolicyViewOutput {
    func didPressTermsCell() {
        router.goToTermsOfUse()
    }
    
    func didPressPolicyCell() {
        router.goToPrivacyPolicy()
    }
    
    func viewWillBecomeActive() {
        interactor.getCellData()
    }
}

extension TermsAndPolicyPresenter: TermsAndPolicyInteractorOutput {
    func cellsDataForTermsAndPolicyList(array: [String]) {
        view.showCellsData(array: array)
    }
}

extension TermsAndPolicyPresenter: TermsAndPolicyModuleInput {
    
}
