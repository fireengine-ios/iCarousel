//
//  AutoSyncAutoSyncViewOutput.swift
//  Depo
//
//  Created by Oleg on 16/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol AutoSyncViewOutput {
    func viewIsReady()
    func skipForNowPressed()
    func change(settings: AutoSyncSettings)
    func save(settings: AutoSyncSettings)
    func enableAutoSync()
}
