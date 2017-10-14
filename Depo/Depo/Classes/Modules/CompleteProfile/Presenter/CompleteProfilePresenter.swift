//
//  CompleteProfileCompleteProfilePresenter.swift
//  Depo
//
//  Created by Oleg on 27/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class CompleteProfilePresenter: CompleteProfileModuleInput, CompleteProfileViewOutput, CompleteProfileInteractorOutput {

    weak var view: CompleteProfileViewInput!
    var interactor: CompleteProfileInteractorInput!
    var router: CompleteProfileRouterInput!

    func viewIsReady() {

    }
}
