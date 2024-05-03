//
//  RafflePresenter.swift
//  Depo
//
//  Created by Ozan Salman on 26.03.2024.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import Foundation

class RafflePresenter {
    var view: RaffleViewInput?
    var interactor: RaffleInteractorInput!
    var router: RaffleRouterInput!
    
}

extension RafflePresenter: RaffleInteractorOutput {
    func successRaffleStatus(status: RaffleStatusResponse) {
        view?.successRaffleStatus(status: status)
    }
    
    func failRaffleStatus(error: String) {
        view?.failRaffleStatus(error: error)
    }
}

extension RafflePresenter: RaffleViewOutput {
    func getRaffleStatus(id: Int) {
        interactor.getRaffleStatus(id: id)
    }
    
    func goToRaffleSummary(statusResponse: RaffleStatusResponse?) {
        router.goToRaffleSummary(statusResponse: statusResponse)
    }
    
    func goToRaffleCondition(statusResponse: RaffleStatusResponse?, conditionImageUrl: String) {
        router.goToRaffleCondition(statusResponse: statusResponse, conditionImageUrl: conditionImageUrl)
    }
}
