//
//  TurkcellSecurityTurkcellSecurityPresenter.swift
//  Depo
//
//  Created by AlexanderP on 19/12/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class TurkcellSecurityPresenter {
    weak var view: TurkcellSecurityViewInput?
    var interactor: TurkcellSecurityInteractorInput!
    var router: TurkcellSecurityRouterInput!
}

// MARK: TurkcellSecurityViewOutput
extension TurkcellSecurityPresenter: TurkcellSecurityViewOutput {
    func viewIsReady() {

    }
}

// MARK: TurkcellSecurityInteractorOutput
extension TurkcellSecurityPresenter: TurkcellSecurityInteractorOutput {

}

// MARK: TurkcellSecurityModuleInput
extension TurkcellSecurityPresenter: TurkcellSecurityModuleInput {

}
