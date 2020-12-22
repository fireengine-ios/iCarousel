//
//  DropboxStatusValue.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 11/8/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

enum DropboxStatusValue: String {
    case pending = "PENDING"
    case running = "RUNNING"
    case failed = "FAILED"
    case waitingAction = "WAITING_ACTION"
    case scheduled = "SCHEDULED"
    case finished = "FINISHED"
    case cancelled = "CANCELLED"
    case none = ""
}
