//
//  ActivityTimelineActivityTimelineViewInput.swift
//  Depo
//
//  Created by Yaroslav Bondar on 13/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol ActivityTimelineViewInput: AnyObject, Waiting {
    func displayTimelineActivities(with array: [ActivityTimelineServiceResponse])
    func refreshTimelineActivities(with array: [ActivityTimelineServiceResponse])
    func endInfinityScrollWithNoMoreData()
}
