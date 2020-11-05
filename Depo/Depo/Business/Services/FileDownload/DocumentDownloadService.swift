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
    
    
    func saveLocaly(remoteItems: [Item], onEachDownload: @escaping VoidHandler, onCompletion: @escaping DocumentDownloadHandler) {
        guard !remoteItems.isEmpty else {
            return
        }
        
        var operations = [DocumentDownloadOperation]()
        
        let operation = DocumentDownloadOperation(items: remoteItems, onDownload: onEachDownload, onCompletion: onCompletion)
        operations.append(operation)
        DocumentDownloadService.operationQueue.addOperations(operations, waitUntilFinished: false)
    }
}

