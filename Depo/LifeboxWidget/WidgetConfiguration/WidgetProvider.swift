//
//  WidgetProvider.swift
//  Depo
//
//  Created by Roman Harhun on 01/09/2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation
import SwiftUI
import WidgetKit

typealias WidgetBaseEntriesCallback = ([WidgetBaseEntry]) -> ()
typealias WidgetBaseEntryCallback = (WidgetBaseEntry?) -> ()
typealias WidgetBaseEntryAndOrderCallback = (_ entry: WidgetBaseEntry?, _ order: WidgetStateOrder?) -> ()
typealias WidgetTimeLineCallback = (Timeline<WidgetBaseEntry>) -> Void

//MARK:- widget general
final class WidgetProvider: TimelineProvider {
    typealias Entry = WidgetBaseEntry
    let defaultOrdersCheckList: [WidgetStateOrder] = [.login, .quota, .freeUpSpace, .syncInProgress, .autosync, .contactsNoBackup, .fir]

    private let timelineManager = WidgetTimelineManager()
    private let privateQueue = DispatchQueue(label: DispatchQueueLabels.widgetProviderQueue)
    
    init() {
        WidgetPresentationService.shared.delegate = self
    }
    
    func placeholder(in context: Context) -> WidgetBaseEntry {
        if let entry = WidgetPresentationService.shared.lastWidgetEntry {
            return entry
        }
        return WidgetLoginRequiredEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetBaseEntry) -> Void) {
        if let entry = WidgetPresentationService.shared.lastWidgetEntry {
            completion(entry)
            return
        }
        
        getTimeline(in: context) { timeline in
            if let entry = timeline.entries.first {
                completion(entry)
            } else {
                completion(WidgetLoginRequiredEntry(date: Date()))
            }
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping WidgetTimeLineCallback) {
        calculateCurrentOrderTimeline(family: context.family, timelineCallback: completion)
    }
}

//MARK:- widget order check
extension WidgetProvider {
    
    private func calculateCurrentOrderTimeline(family: WidgetFamily, timelineCallback: @escaping WidgetTimeLineCallback) {
        
        DebugLogService.debugLog("Calculating order TIMELINE, family: \(family.debugDescription)")
        
        privateQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            self.timelineManager.provideTimeline(family: family, orders: self.defaultOrdersCheckList
                                            , timelineCallback: timelineCallback)
        }
    }
}

extension WidgetProvider: WidgetPresentationServiceDelegate {
    func didLogout() {
        timelineManager.cancelAll()
    }
}
