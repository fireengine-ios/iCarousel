//
//  SharedEnums.swift
//  Depo
//
//  Created by Konstantin on 2/8/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation


enum AutoSyncStatus: String {
    case undetermined
    case waitingForWifi
    case prepairing
    case executing
    case stopped
    case synced
    case failed
}

enum WidgetSyncStatus: String {
    case undetermined
    case executing
    case stopped
    case synced
}
