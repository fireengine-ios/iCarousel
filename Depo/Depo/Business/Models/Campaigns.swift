//
//  Campaigns.swift
//  Depo
//
//  Created by Rustam on 12.06.24.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import Foundation

// MARK: - Campaign
struct Campaign: Codable {
    let id: Int?
    let imagePath, detailImagePath: String?
    let conditionImagePath: String?
    let title, name, description: String?
    let startDate, endDate: Int?
    let extraData: ExtraData?
}

// MARK: - ExtraData
struct ExtraData: Codable {
    let buttons: [Button]?
}

// MARK: - Button
struct Button: Codable {
    let text, url, action: String?
}
