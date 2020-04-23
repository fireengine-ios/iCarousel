//
//  AutoSyncAutoSyncViewOutput.swift
//  Depo
//
//  Created by Oleg on 16/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol AutoSyncViewOutput {
    func viewIsReady()
    func change(settings: AutoSyncSettings, albums: [AutoSyncAlbum])
    func save(settings: AutoSyncSettings, albums: [AutoSyncAlbum])
    func checkPermissions()
}
