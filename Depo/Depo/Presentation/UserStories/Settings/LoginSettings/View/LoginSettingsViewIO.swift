//
//  TurkcellSecurityViewIO.swift
//  Depo
//
//  Created by AlexanderP on 19/12/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol LoginSettingsViewInput: class {
    func updateTableView()
}

protocol LoginSettingsViewOutput: class {    
    var cellsData: [SettingsTableViewSwitchCell.CellType: Bool] { get }
    var cellTypes: [SettingsTableViewSwitchCell.CellType] { get }
    
    func viewIsReady()
    func updateStatus(type: SettingsTableViewSwitchCell.CellType, isOn: Bool)
}
