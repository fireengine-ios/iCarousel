//
//  HelpAndSupportHelpAndSupportPresenter.swift
//  Depo
//
//  Created by Oleg on 12/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class HelpAndSupportPresenter: HelpAndSupportModuleInput, HelpAndSupportViewOutput, HelpAndSupportInteractorOutput {

    weak var view: HelpAndSupportViewInput!
    var interactor: HelpAndSupportInteractorInput!
    var router: HelpAndSupportRouterInput!

    func viewIsReady() {
        interactor.trackScreen()
    }
}
