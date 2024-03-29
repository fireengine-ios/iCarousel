//
//  RaffleInteractorOutput.swift
//  Depo
//
//  Created by Ozan Salman on 26.03.2024.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import Foundation

protocol RaffleInteractorOutput {
    func successRaffleStatus(status: RaffleStatusResponse)
    func failRaffleStatus(error: String)
}
