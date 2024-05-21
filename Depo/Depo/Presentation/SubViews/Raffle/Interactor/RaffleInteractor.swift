//
//  RaffleInteractor.swift
//  Depo
//
//  Created by Ozan Salman on 26.03.2024.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import Foundation

class RaffleInteractor {
    
    var output: RaffleInteractorOutput!
    private lazy var service = RaffleService()
   
    func raffleStatus(id: Int) {
        service.getRaffleStatus(id: id) { [weak self] result in
            switch result {
            case .success(let response):
                self?.output.successRaffleStatus(status: response)
            case .failed(let error):
                self?.output.failRaffleStatus(error: error.description)
            }
        }
    }
}

extension RaffleInteractor: RaffleInteractorInput {
    func getRaffleStatus(id: Int) {
        raffleStatus(id: id)
    }
}
