//
//  DebugAnalyticsService.swift
//  Depo
//
//  Created by Konstantin Studilin on 04/12/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation
import Crashlytics


enum DebugAnalyticsEevnt: String {
    case zeroContentLength
    case test
}


final class DebugAnalyticsService {
    
    static func log(event: DebugAnalyticsEevnt, attributes: [String : Any] = [:]) {
        Answers.logCustomEvent(withName: event.rawValue, customAttributes: attributes)
    }
}
