//
//  RaffleRouterInput.swift
//  Depo
//
//  Created by Ozan Salman on 26.03.2024.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import Foundation

protocol RaffleRouterInput {
    func goToRaffleSummary(statusResponse: RaffleStatusResponse?, campaignId: Int)
    func goToRaffleCondition(statusResponse: RaffleStatusResponse?, conditionImageUrl: String, campaignId: Int)
}
