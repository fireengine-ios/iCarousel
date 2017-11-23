//
//  WelcomeWelcomePresenter.swift
//  Depo
//
//  Created by Oleg on 26/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class WelcomePresenter: WelcomeModuleInput, WelcomeViewOutput, WelcomeInteractorOutput {

    weak var view: WelcomeViewInput!
    var interactor: WelcomeInteractorInput!
    var router: WelcomeRouterInput!

    func viewIsReady() {

    }
}
