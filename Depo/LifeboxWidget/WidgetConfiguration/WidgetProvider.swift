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

    let defaultOrdersCheckList: [WidgetStateOrder] = [.login, .quota, .freeUpSpace, .autosync, .contactsNoBackup, .fir]

    private let timelineManager = WidgetTimelineManager()
    
    init() {
        DebugLogService.debugLog("WIDGET: WidgetProvider init")
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
        DebugLogService.debugLog("Widget: getTimeline \(context.family.debugDescription)")
        calculateCurrentOrderTimeline(family: context.family, timelineCallback: { result in
            DebugLogService.debugLog("Widget: getTimeline ready \(context.family.debugDescription)")
            completion(result)
        })
    }
}

//MARK:- widget order check
extension WidgetProvider {
    
    private func calculateCurrentOrderTimeline(family: WidgetFamily, timelineCallback: @escaping WidgetTimeLineCallback) {
        
        timelineManager.getQueue(family: family)?.async { [weak self] in
            guard let self = self else {
                return
            }
            self.timelineManager.provideTimeline(family: family, orders: self.defaultOrdersCheckList) { result in
                switch result {
                case .success(let timeline):
                    timelineCallback(timeline)
                case .failure(let failStatus):
                    switch failStatus {
                    case .cancel:
                        DebugLogService.debugLog("Widget: Timeline cancelled for \(family.debugDescription)")
                    case .error(let error):
                        DebugLogService.debugLog("Widget: Timeline got error \(error.localizedDescription) for \(family.debugDescription)")
                    }
                }
            }
        }
    }
}

extension WidgetProvider: WidgetPresentationServiceDelegate {
    func didLogout() {
        DebugLogService.debugLog("WIDGET: WidgetProvider delegate did call logout")
        WidgetPresentationService.shared.lastWidgetEntry = nil
        WidgetServerService.shared.clearToken()
        timelineManager.cancelAll()
    }
}
