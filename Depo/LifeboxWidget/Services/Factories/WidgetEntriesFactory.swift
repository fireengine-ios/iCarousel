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
    
    func findFirstFittingEntry(family: WidgetFamily, orders: [WidgetStateOrder], customCurrentDate: Date? = nil, entryCallback: @escaping EntryCreationResultCallback) {
        
        let entriesConstructionOperation = WidgetEntryConstructionOperation(ordersCheckList: orders, callback: entryCallback)

        getOperationQueue(family: family)?.addOperation(entriesConstructionOperation)
    }
    
    func cancellAll() {
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
}
