//
//  CampaignStatusResponse.swift
//  Depo
//
//  Created by Ozan Salman on 24.02.2024.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import Foundation

enum CampaignStatus: String, Codable {
    case allowed = "ALLOWED"
    case notAllowed = "NOT_ALLOWED"
    case alreadyParticipated = "ALREADY_PARTICIPATED"
}

struct CampaignStatusResponse: Codable {
    let result: CampaignStatus?
}
