//
//  DocumentDownloadService.swift
//  Depo
//
//  Created by Konstantin Studilin on 29.10.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//


import UIKit


final class DocumentDownloadService {
    
    static let operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    
    func saveLocaly(remoteItems: [Item], onDownload: @escaping DocumentDownloadHandler) -> Int {
        guard !remoteItems.isEmpty else {
            return 0
        }
        
        var operations = [DocumentDownloadOperation]()
        
        let operation = DocumentDownloadOperation(items: remoteItems, completion: onDownload)
        operations.append(operation)
        DocumentDownloadService.operationQueue.addOperations(operations, waitUntilFinished: false)
        return operations.count
    }
}

