//
//  ActivitiesByMinutesAndType.swift
//  Depo_LifeTech
//
//  Created by user on 9/18/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

class ActivitiesByMinutesAndType {
    let date: Date
    let type: ActivityType
    var list: [ActivityTimelineServiceResponse] = []
    
    init(date: Date, type: ActivityType) {
        self.date = date
        self.type = type
    }
}
