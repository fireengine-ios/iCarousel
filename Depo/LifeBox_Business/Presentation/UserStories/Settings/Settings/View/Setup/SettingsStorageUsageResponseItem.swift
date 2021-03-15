//
//  SettingsStorageUsageResponseItem.swift
//  Depo
//
//  Created by Anton Ignatovich on 12.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation

struct SettingsStorageUsageResponseItem: Codable {
    let type: String?
    let uuid: String?
    let name: String?
    let surname: String?
    let email: String?
    let fileCount: Int?

    let unlimitedStorage: Bool?
    let usageInBytes: Int64
    let usage: String?
    let storageInBytes: Int64?
}
