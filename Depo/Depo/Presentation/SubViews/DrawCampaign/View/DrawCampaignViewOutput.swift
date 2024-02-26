//
//  DrawCampaignViewOutput.swift
//  Depo
//
//  Created by Ozan Salman on 24.02.2024.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import Foundation

protocol DrawCampaignViewOutput {
    func getCampaignStatus(campaignId: Int)
    func getCampaignPolicy(campaignId: Int)
    func setCampaignApply(campaignId: Int)
}
