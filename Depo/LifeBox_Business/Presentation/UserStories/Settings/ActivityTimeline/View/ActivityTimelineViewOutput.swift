//
//  ActivityTimelineActivityTimelineViewOutput.swift
//  Depo
//
//  Created by Yaroslav Bondar on 13/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol ActivityTimelineViewOutput {
    func viewIsReady()
    func updateForPullToRefresh()
    func loadMoreActivities()
}
