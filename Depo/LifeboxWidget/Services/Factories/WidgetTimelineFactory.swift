//
//  WidgetTimelineFactory.swift
//  Depo
//
//  Created by Alex Developer on 09.10.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation
import WidgetKit

final class
{
    
    private let privateQueue = DispatchQueue(label: DispatchQueueLabels.widgetProviderQueue)
    private let entriesFactory = WidgetEntriesFactory()
    private var isCancelled = false
    
    private let timelinesCreationQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        return operationQueue
    }()
//    private(set) var lastEntry
//    WidgetPresentationService.shared.lastWidgetEntry
    
    func provideTimeline(family: WidgetFamily, orders: [WidgetStateOrder], timelineCallback: @escaping WidgetTimeLineCallback) {
        isCancelled = false
        
        var newEntries = [WidgetBaseEntry]()
        let semaphore = DispatchSemaphore(value: 0)
        entriesFactory.findFirstFittingEntry(orders: orders) { [weak self] entry, order  in
            guard
                let self = self,
                !self.isCancelled
            else {
                return
            }
            self.privateQueue.async { [weak self] in
                guard
                    let self = self,
                    !self.isCancelled,
                    let preparedEntry = entry,
                    let order = order
                else {
                    return
                }
                newEntries.append(preparedEntry)
                //if found sync successful need to add next one
                if order.isContained(in: [.syncInProgress, .syncComplete]),
                   preparedEntry.state == .syncComplete,
                   let slice = orders.split(separator: order).last {
                    
                    let nextOrdersInLine: [WidgetStateOrder] = Array(slice)
                    
                    self.entriesFactory.findFirstFittingEntry(orders: nextOrdersInLine, customCurrentDate: order.refreshDate) { [weak self] (nextEntry, entryOrder) in
                        guard
                            let self = self,
                            !self.isCancelled
                        else {
                            semaphore.signal()
                            return
                        }
                        if let newEntry = nextEntry {
                            newEntries.append(newEntry)
                            DebugLogService.debugLog("found first fitting entry \(entryOrder.debugDescription), family\(family.debugDescription)")
                        }
                        semaphore.signal()
                    }
                    semaphore.wait()
                }
                guard !self.isCancelled else {
                    return
                }
                
                let timelineOperation = WidgetTimelineConstructionOperation(entries: newEntries, order: order) { [weak self] timeline in
                    guard
                        let self = self,
                        !self.isCancelled
                    else {
                        return
                    }
                    timelineCallback(timeline)
                }
                
                self.save(entry: newEntries.last)
                self.timelinesCreationQueue.addOperation(timelineOperation)
                
            }
        }
        
    }
    
    private func save(entry: WidgetBaseEntry?) {
        if let entry = entry, WidgetPresentationService.shared.lastWidgetEntry?.state != entry.state {
            WidgetPresentationService.shared.notifyChangeWidgetState(entry.state)
        }
        
        WidgetPresentationService.shared.lastWidgetEntry = entry
    }
    
    func cancellAll() {
        isCancelled = true
        timelinesCreationQueue.cancelAllOperations()
        entriesFactory.cancellAll()
    }
    
}
