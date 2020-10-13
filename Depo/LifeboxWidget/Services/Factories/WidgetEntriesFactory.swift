//
//  WidgetEntriesFactory.swift
//  Depo
//
//  Created by Alex Developer on 09.10.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation
import WidgetKit

final class WidgetEntriesFactory {
    
    private var isSmallCancelled = false
    private var isMediumCancelled = false
    
    private let entriesSmallCreationQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        return operationQueue
    }()
    
    private let entriesMediumCreationQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        return operationQueue
    }()
    
    func findFirstFittingEntry(family: WidgetFamily, orders: [WidgetStateOrder], customCurrentDate: Date? = nil, entryCallback: @escaping WidgetBaseEntryAndOrderCallback) {
        
        setCancelledStatus(family: family, status: false)
        
        let entriesConstructionOperation = WidgetEntryConstructionOperation(ordersCehckList: orders) { [weak self] entry, order in
            guard
                let self = self,
                !self.isFamilyTimelineCancelled(family: family)
            else {
                return
            }
            entryCallback(entry, order)
        }
        getOperationQueue(family: family)?.addOperation(entriesConstructionOperation)
    }
    
    func cancellAll() {
        isSmallCancelled = true
        isMediumCancelled = true
        entriesMediumCreationQueue.cancelAllOperations()
        entriesSmallCreationQueue.cancelAllOperations()
    }
    
    func getOperationQueue(family: WidgetFamily) -> OperationQueue? {
        if family == .systemMedium {
            return entriesMediumCreationQueue
        } else if family == .systemSmall {
            return entriesSmallCreationQueue
        } else {
            return nil
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
    
}
