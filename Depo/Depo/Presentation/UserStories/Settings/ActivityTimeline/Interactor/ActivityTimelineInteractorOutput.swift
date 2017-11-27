//
//  ActivityTimelineActivityTimelineInteractorOutput.swift
//  Depo
//
//  Created by Yaroslav Bondar on 13/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol ActivityTimelineInteractorOutput: class {
    func successedTimelineActivities(with array: [ActivityTimelineServiceResponse])
    func refreshTimelineActivities(with array: [ActivityTimelineServiceResponse])
    func failedTimelineActivities(with error: ErrorResponse)
}
