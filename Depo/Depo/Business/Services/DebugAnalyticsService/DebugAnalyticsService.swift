//
//  DebugAnalyticsService.swift
//  Depo
//
//  Created by Konstantin Studilin on 04/12/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation
import Crashlytics


enum DebugAnalyticsEvent: String {
    case zeroContentLength
    case coreDataError
    case test
}


final class DebugAnalyticsService {
    
    static func log(event: DebugAnalyticsEvent, attributes: [String : Any] = [:]) {
        Answers.logCustomEvent(withName: event.rawValue, customAttributes: attributes)
    }
}
