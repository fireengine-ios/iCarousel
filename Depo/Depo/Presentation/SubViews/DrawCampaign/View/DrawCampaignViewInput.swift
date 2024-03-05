//
//  DrawCampaignViewInput.swift
//  Depo
//
//  Created by Ozan Salman on 24.02.2024.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import Foundation

protocol DrawCampaignViewInput {
    func successCampaignStatus(status: CampaignStatus)
    func failCampaignStatus(error: String)
    func successCampaignPolicy(response: CampaignPolicyResponse)
    func failCampaignPolicy(error: String)
    func successCampaignApply(response: CampaignApplyResponse)
}
