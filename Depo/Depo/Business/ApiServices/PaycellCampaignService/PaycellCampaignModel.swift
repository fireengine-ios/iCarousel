//
//  PaycellCampaignModel.swift
//  Depo
//
//  Created by Burak Donat on 8.08.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

struct PaycellLinkResponse: Codable {
    let link: String
}

struct PaycellDetailResponse: Codable {
    let status: String
    let value: PaycellDetailModel
}

struct PaycellDetailModel: Codable {
    let locale, title, content, image: String
}
