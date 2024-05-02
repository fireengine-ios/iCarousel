//
//  RaffleViewOutput.swift
//  Depo
//
//  Created by Ozan Salman on 26.03.2024.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import Foundation

protocol RaffleViewOutput {
    func getRaffleStatus(id: Int)
    func goToRaffleSummary(statusResponse: RaffleStatusResponse?)
    func goToRaffleCondition(statusResponse: RaffleStatusResponse?, conditionImageUrl: String)
}
