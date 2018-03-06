//
//  SyncedBlock.swift
//  Depo
//
//  Created by Oleg on 22.02.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

class SyncedBlock {
    static func synced(_ lock: Any, closure: VoidHandler) {
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }
}
