//
//  SettingsSettingsViewInput.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol SettingsViewInput: class {
    func prepareCellsData()
    func updateUserDataUsageSection(usageData: SettingsStorageUsageResponseItem?)
}
