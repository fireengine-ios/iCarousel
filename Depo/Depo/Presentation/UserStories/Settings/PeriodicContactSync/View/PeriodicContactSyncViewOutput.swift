//
//  PeriodicContactSyncViewOutput.swift
//  Depo
//
//  Created by Brothers Harhun on 18.04.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

protocol PeriodicContactSyncViewOutput: AnyObject {
    func viewIsReady(tableView: UITableView)
    func saveSettings()
}
