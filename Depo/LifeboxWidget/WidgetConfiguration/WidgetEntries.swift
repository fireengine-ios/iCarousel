//
//  WidgetEntry.swift
//  Depo
//
//  Created by Roman Harhun on 01/09/2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation
import SwiftUI
import WidgetKit

class WidgetBaseEntry: TimelineEntry {
    let date: Date
    init(date: Date) {
        self.date = date
    }
}

final class WidgetLoginRequiredEntry: WidgetBaseEntry { }

final class WidgetQuotaEntry: WidgetBaseEntry {
    let usedPercentage: Int
    
    init(usedPercentage: Int, date: Date) {
        self.usedPercentage = usedPercentage
        super.init(date: date)
    }
}

final class WidgetDeviceQuotaEntry: WidgetBaseEntry {
    let usedPersentage: Int
    
    init(usedPersentage: Int, date: Date) {
        self.usedPersentage = usedPersentage
        super.init(date: date)
    }
}

final class WidgetContactBackupEntry: WidgetBaseEntry {
    let backupDate: Date?
    
    init(backupDate: Date? = nil, date: Date) {
        self.backupDate = backupDate
        super.init(date: date)
    }
}

final class WidgetUserInfoEntry: WidgetBaseEntry {
    let isFIREnabled: Bool
    let isPremiumUser: Bool

    init(isFIREnabled: Bool, isPremiumUser: Bool, date: Date) {
        self.isFIREnabled = isFIREnabled
        self.isPremiumUser = isPremiumUser
        super.init(date: date)
    }
}

final class WidgetAutoSyncEntry: WidgetBaseEntry {
    let hasUnsynced: Bool
    let isSyncEnabled: Bool
    
    init(hasUnsynced: Bool, isSyncEnabled: Bool, date: Date) {
        self.hasUnsynced = hasUnsynced
        self.isSyncEnabled = isSyncEnabled
        
        super.init(date: date)
    }
}
