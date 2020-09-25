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
    let peopleInfos: [PeopleInfo]
    let images: [UIImage]

    init(isFIREnabled: Bool, isPremiumUser: Bool, peopleInfos: [PeopleInfo], images: [UIImage], date: Date) {
        self.isFIREnabled = isFIREnabled
        self.isPremiumUser = isPremiumUser
        self.peopleInfos = peopleInfos
        self.images = images
        super.init(date: date)
    }
}

final class WidgetAutoSyncEntry: WidgetBaseEntry {
    let isSyncEnabled: Bool
    let isAppLaunched: Bool
    
    init(isSyncEnabled: Bool, isAppLaunched: Bool, date: Date) {
        self.isSyncEnabled = isSyncEnabled
        self.isAppLaunched = isAppLaunched
        
        super.init(date: date)
    }
}

final class WidgetSyncInProgressEntry: WidgetBaseEntry {
    let uploadCount: Int
    let totalCount: Int
    let currentFileName: String
    
    var isSyncComplete: Bool {
        uploadCount == totalCount
    }
    
    init(uploadCount: Int, totalCount: Int, currentFileName: String, date: Date) {
        self.uploadCount = uploadCount
        self.totalCount = totalCount
        self.currentFileName = currentFileName
        
        super.init(date: date)
    }
}
