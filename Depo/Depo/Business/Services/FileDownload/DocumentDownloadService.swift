//
//  DocumentDownloadService.swift
//  Depo
//
//  Created by Konstantin Studilin on 29.10.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//


import UIKit


final class DocumentDownloadService {
    
    private let operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    
    func saveLocaly(remoteItems: [Item], onDownload: @escaping VoidHandler, onCompletion: @escaping ValueHandler<[URL]>) -> Int {
        guard !remoteItems.isEmpty else {
            return 0
        }
        
        var localURLs = [URL]()
        var operations = [DocumentDownloadOperation]()
        
        let group = DispatchGroup()
        
        remoteItems.forEach {
            group.enter()
            let operation = DocumentDownloadOperation(item: $0) { localURL in
                if let url = localURL {
                    localURLs.append(url)
                }
                onDownload()
                group.leave()
            }
            operations.append(operation)
        }
        operationQueue.addOperations(operations, waitUntilFinished: false)
        
        group.notify(queue: .main) {
            onCompletion(localURLs)
        }
         
        return operations.count
    }
}

