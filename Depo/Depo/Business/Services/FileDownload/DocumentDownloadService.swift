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
    
    
    func saveLocaly(remoteItems: [Item]) {
        guard !remoteItems.isEmpty else {
            return
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
                group.leave()
            }
            operations.append(operation)
        }
        
        operationQueue.addOperations(operations, waitUntilFinished: false)
        
        group.notify(queue: .main) {
            self.showDocumentPicker(urls: localURLs)
        }
    }
    
    private func showDocumentPicker(urls: [URL]) {
        let picker = UIDocumentPickerViewController(urls: urls, in: .exportToService)
        RouterVC().presentViewController(controller: picker)
    }
}

