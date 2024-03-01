//
//  CampaignPolicyResponse.swift
//  Depo
//
//  Created by Ozan Salman on 24.02.2024.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import Foundation

struct CampaignPolicyResponse: Codable {
    let title, description, thumbnail, content: String
    let createdDate: Int
}
