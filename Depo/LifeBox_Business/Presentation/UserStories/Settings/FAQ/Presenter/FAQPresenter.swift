//
//  FAQPresenter.swift
//  Depo
//
//  Created by Oleg on 12/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class FAQPresenter: FAQModuleInput, FAQViewOutput, FAQInteractorOutput {

    weak var view: FAQViewInput!
    var interactor: FAQInteractorInput!
    var router: FAQRouterInput!

    func viewIsReady() {
        interactor.trackScreen()
    }
}
