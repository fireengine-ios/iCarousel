//
//  Date+Seconds.swift
//  Depo_LifeTech
//
//  Created by user on 9/18/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

extension Date {
    var withoutSeconds: Date {
        let time = floor(timeIntervalSinceReferenceDate / 60.0) * 60.0
        return Date(timeIntervalSinceReferenceDate: time)
    }
}
