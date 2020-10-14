//
//  WidgetTimelineConstructionOperation.swift
//  Depo
//
//  Created by Alex Developer on 09.10.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation
import WidgetKit

final class WidgetTimelineConstructionOperation: Operation {

    private let callback: WidgetTimeLineCallback
    private let entries: [WidgetBaseEntry]
    private let order: WidgetStateOrder
    
    init(entries: [WidgetBaseEntry], order: WidgetStateOrder, timelineCallback: @escaping WidgetTimeLineCallback) {
        callback = timelineCallback
        self.entries = entries
        self.order = order
    }
    
    override func cancel() {
        super.cancel()
    }
    
    override func main() {
        guard !isCancelled else {
            return
        }
        switch order {
        case .login: //ORDER-0
            callback(Timeline(entries: entries, policy: .never))
        case .quota, .freeUpSpace, .autosync, .contactsNoBackup, .oldContactsBackup, .fir, .syncInProgress, .syncComplete:  //ORDER 1-7
            let refreshDate = order.refreshDate ?? Date()
            callback(Timeline(entries: entries, policy: .after(refreshDate)))
        }
    }
    
}
