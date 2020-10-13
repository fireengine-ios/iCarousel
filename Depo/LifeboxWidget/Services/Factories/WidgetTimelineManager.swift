//
//  WidgetTimelineFactory.swift
//  Depo
//
//  Created by Alex Developer on 09.10.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation
import WidgetKit

enum EntryError: Error {
    case cancel
    case error(Error)
}

typealias EntryCreationResult = Result<(WidgetBaseEntry?, WidgetStateOrder?), EntryError>
typealias TimelineCreationResult = Result<Timeline<WidgetBaseEntry>, EntryError>
typealias EntryCreationResultCallback = (EntryCreationResult) -> Void
typealias TimelineCreationResultCallback = (TimelineCreationResult) -> Void

final class WidgetTimelineManager {
    
    private let privateSmallQueue = DispatchQueue(label: DispatchQueueLabels.widgetSmallProviderQueue)
    private let privateMediumQueue = DispatchQueue(label: DispatchQueueLabels.widgetMediumProviderQueue)
    private let entriesFactory = WidgetEntriesFactory()
    private var isSmallCancelled = false
    private var isMediumCancelled = false
    
    private let timelinesMediumWidgetQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        return operationQueue
    }()
    
    private let timelinesSmallWidgetQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        return operationQueue
    }()
    
    func provideTimeline(family: WidgetFamily, orders: [WidgetStateOrder], timelineCallback: @escaping TimelineCreationResultCallback) {

        setCancelledStatus(family: family, status: false)
        
        var newEntries = [WidgetBaseEntry]()
        let semaphore = DispatchSemaphore(value: 0)
        entriesFactory.findFirstFittingEntry(family: family, orders: orders) { [weak self] result in

            guard
                let self = self,
                !self.isFamilyTimelineCancelled(family: family)
            else {
                timelineCallback(.failure(.cancel))
                return
            }
            
            switch result {
            case .success((let entry, let order)):
                self.getQueue(family: family)?.async { [weak self] in
                    guard
                        let self = self,
                        !self.isFamilyTimelineCancelled(family: family),
                        let preparedEntry = entry,
                        let order = order
                    else {
                        timelineCallback(.failure(.cancel))
                        return
                    }
                    newEntries.append(preparedEntry)
                    //if found sync successful need to add next one
                    if order.isContained(in: [.syncInProgress, .syncComplete]),
                       preparedEntry.state == .syncComplete,
                       let slice = orders.split(separator: order).last {
                        
                        let nextOrdersInLine: [WidgetStateOrder] = Array(slice)
                        
                        self.entriesFactory.findFirstFittingEntry(family: family, orders: nextOrdersInLine, customCurrentDate: order.refreshDate) { [weak self] result in
    
                            guard
                                let self = self,
                                !self.isFamilyTimelineCancelled(family: family)
                            else {
                                semaphore.signal()
                                timelineCallback(.failure(.cancel))
                                return
                            }
                            
                            switch result {
                            case .success((let nextEntry, _)):
                                if let newEntry = nextEntry {
                                    newEntries.append(newEntry)
                                    DebugLogService.debugLog("found first fitting entry \(newEntry.state.gaName), family\(family.debugDescription)")
                                }
                            case .failure(let failStatus):
                                switch failStatus {
                                case .cancel:
                                    timelineCallback(.failure(.cancel))
                                case .error(let error):
                                    timelineCallback(.failure(.error(error)))
                                }
                            }
                            semaphore.signal()
                        }
                        semaphore.wait()
                    }
                    guard !self.isFamilyTimelineCancelled(family: family) else {
                        return
                    }
                    
                    let timelineOperation = WidgetTimelineConstructionOperation(entries: newEntries, order: order) { [weak self] timeline in
                        guard
                            let self = self,
                            !self.isFamilyTimelineCancelled(family: family)
                        else {
                            timelineCallback(.failure(.cancel))
                            return
                        }
                        timelineCallback(.success(timeline))
                    }
                    
                    self.save(entry: newEntries.last)
                    self.getOperationQueue(family: family)?.addOperation(timelineOperation)
                }
            case .failure(let failStatus):
                switch failStatus {
                case .cancel:
                    timelineCallback(.failure(.cancel))
                case .error(let error):
                    timelineCallback(.failure(.error(error)))
                }
            }
        }
    }
    
    private func isFamilyTimelineCancelled(family: WidgetFamily) -> Bool {
        if family == .systemMedium {
            return isMediumCancelled
        } else if family == .systemSmall {
            return isSmallCancelled
        } else {
            return true
        }
    }
    
    private func setCancelledStatus(family: WidgetFamily, status: Bool) {
        if family == .systemMedium {
            isMediumCancelled = status
        } else if family == .systemSmall {
            isSmallCancelled = status
        }
    }
    
    func getQueue(family: WidgetFamily) -> DispatchQueue? {
        if family == .systemMedium {
            return privateMediumQueue
        } else if family == .systemSmall {
            return privateSmallQueue
        } else {
            return nil
        }
    }
    
    private func getOperationQueue(family: WidgetFamily) -> OperationQueue? {
        if family == .systemMedium {
            return timelinesMediumWidgetQueue
        } else if family == .systemSmall {
            return timelinesSmallWidgetQueue
        } else {
            return nil
        }
    }
    
    private func save(entry: WidgetBaseEntry?) {
        if let entry = entry, WidgetPresentationService.shared.lastWidgetEntry?.state != entry.state {
            WidgetPresentationService.shared.notifyChangeWidgetState(entry.state)
        }
        
        WidgetPresentationService.shared.lastWidgetEntry = entry
    }
    
    func cancelAll() {
        isSmallCancelled = true
        isMediumCancelled = true
        timelinesMediumWidgetQueue.cancelAllOperations()
        timelinesSmallWidgetQueue.cancelAllOperations()
        entriesFactory.cancellAll()
    }
}
