//
//  HomeHeaderHomeHeaderPresenter.swift
//  Depo
//
//  Created by Oleg on 28/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class HomeHeaderPresenter: HomeHeaderModuleInput, HomeHeaderViewOutput, HomeHeaderInteractorOutput {

    weak var view: HomeHeaderViewInput!
    var interactor: HomeHeaderInteractorInput!
    var router: HomeHeaderRouterInput!

    func viewIsReady() {

    }
}
