//
//  WidgetEntriesFactory.swift
//  Depo
//
//  Created by Alex Developer on 09.10.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

final class WidgetEntriesFactory {
    
    private var isCancelled = false
    
    private let entriesCreationQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        return operationQueue
    }()
    
    func findFirstFittingEntry(orders: [WidgetStateOrder], customCurrentDate: Date? = nil, entryCallback: @escaping WidgetBaseEntryAndOrderCallback) {
        isCancelled = false
        let entriesConstructionOperation = WidgetEntryConstructionOperation(ordersCehckList: orders) { [weak self] entry, order in
            guard
                let self = self,
                !self.isCancelled
            else {
                return
            }
            entryCallback(entry, order)
        }
        entriesCreationQueue.addOperation(entriesConstructionOperation)
    }
    
    func cancellAll() {
        isCancelled = true
        entriesCreationQueue.cancelAllOperations()
    }
    
}
